const crypto = require('crypto');
const fs = require('fs/promises');
const path = require('path');

const inputEncryptedFolder = 'output-files/outcomes';
const outputDecryptedFolder = 'output-files/decrypted';
const key = 'abcdefghijklmnopqrstuvwxyz';

// Fungsi untuk dekripsi data
const decrypt = (data) => {
    const decipher = crypto.createDecipher('aes-256-cbc', key);
    let decryptedData = decipher.update(data, 'base64', 'base64');
    decryptedData += decipher.final('base64');
    return decryptedData;
};

const downloadFromHelia = async (node, cid, fileData) => {
    const { unixfs } = await import('@helia/unixfs');
    console.log(`Downloading file with CID ${cid} on Node B...`);
    // Print out our node's PeerId
    console.log('PeerID Downloader:', node.libp2p.peerId.toString());
    // Create a Helia node
    const fs_unixfs = await unixfs(node);
    const decoder = new TextDecoder();
    let text = ''
    /* -------THE BUG IS HERE------- 
    masih belum bisa download dari ipfs (hang)
    -------THE BUG IS HERE-------*/
    for await (const chunk of fs_unixfs.cat(cid)) {
        text += decoder.decode(chunk, {
            stream: true
        })
    }
    const encryptedFilePath = path.join(inputEncryptedFolder, `${fileData}.enc`);
    await fs.writeFile(encryptedFilePath, text, 'base64');
    console.log(`File with CID ${cid} downloaded successfully on Node B.`);
}

// Fungsi untuk membaca, mendekripsi, dan menyimpan file
const decryptAndSaveFiles = async () => {
    try {
        // Baca semua file di dalam folder input-files/encrypted
        const files = await fs.readdir(inputEncryptedFolder);

        // Loop melalui setiap file
        for (const file of files) {
            const encryptedFilePath = path.join(inputEncryptedFolder, file);

            // Baca isi file terenkripsi
            const encryptedData = await fs.readFile(encryptedFilePath, 'base64');

            // Dekripsi base64 data
            let decryptedData;
            try {
                decryptedData = decrypt(encryptedData);
            } catch (err) {
                throw new Error(`Decryption error: ${err.message}`);
            }

            // Simpan file terdekripsi di folder output-files/decrypted
            const decryptedFilePath = path.join(outputDecryptedFolder, `${file.replace('.enc', '')}`);
            await fs.writeFile(decryptedFilePath, decryptedData, 'base64');

            console.log(`✅ File ${file} decrypted!`);
        }
    } catch (err) {
        console.error(`❌ Error: ${err.message}`);
    }
};

async function main() {
    const { noise } = await import('@chainsafe/libp2p-noise');
    const { yamux } = await import('@chainsafe/libp2p-yamux');
    const { unixfs } = await import('@helia/unixfs');
    const { bootstrap } = await import('@libp2p/bootstrap');
    const { tcp } = await import('@libp2p/tcp');
    const { MemoryBlockstore } = await import('blockstore-core');
    const { MemoryDatastore } = await import('datastore-core');
    const { createHelia } = await import('helia');
    const { createLibp2p } = await import('libp2p');
    const { identifyService } = await import('libp2p/identify');

    async function createNode() {
        // the blockstore is where we store the blocks that make up files
        const blockstore = new MemoryBlockstore()

        // application-specific data lives in the datastore
        const datastore = new MemoryDatastore()

        // libp2p is the networking layer that underpins Helia
        const libp2p = await createLibp2p({
            datastore,
            addresses: {
                listen: [
                    '/ip4/127.0.0.1/tcp/0',
                    "/ip4/127.0.0.1/tcp/5003",
                    "/ip4/127.0.0.1/tcp/8888",
                    "/ip4/0.0.0.0/tcp/9094",
                    "/ip4/127.0.0.1/tcp/9095",
                    "/ip4/0.0.0.0/tcp/9096",
                    "/ip4/0.0.0.0/udp/9096/quic",
                    "/ip4/127.0.0.1/tcp/9097",
                ]
            },
            transports: [
                tcp()
            ],
            connectionEncryption: [
                noise()
            ],
            streamMuxers: [
                yamux()
            ],
            peerDiscovery: [
                bootstrap({
                    // 3 node hospital dan 3 node insurance
                    list: [
                        "/ip4/127.0.0.1/tcp/4001",
                        "/ip4/127.0.0.1/tcp/4002",
                        "/ip4/127.0.0.1/tcp/5001",
                        "/ip4/127.0.0.1/tcp/5002",
                        "/dns4/ipfs-sardjito/tcp/5001",
                        "/dns4/ipfs-prudential/tcp/5001"
                    ]
                })
            ],
            services: {
                identify: identifyService()
            }
        })

        return await createHelia({
            datastore,
            blockstore,
            libp2p
        })
    }

    // create two helia nodes
    const node = await createNode()
    const { base32 } = await import("multiformats/bases/base32")
    const { CID } = await import('multiformats/cid');
    try {
        const filePath = './metadata.txt';
        const fileContent = await fs.readFile(filePath, 'utf-8');

        // Parse isi file sebagai JSON
        const dataArray = JSON.parse(fileContent);

        // Hitung panjang array
        const arrayLength = dataArray.length;

        // Loop untuk setiap elemen di dalam array dan jalankan downloadFromHelia
        for (let i = 0; i < arrayLength; i++) {
            const currentElement = dataArray[i];

            // Di sini diasumsikan bahwa 'cid' adalah kunci yang digunakan dalam array of objects
            const file = currentElement.file;
            const cid = currentElement.cid;
            const link = CID.parse(cid, base32);
            // Jalankan fungsi downloadFromHelia untuk setiap 'cid'
            await downloadFromHelia(node, link, file);
            console.log(`✅ File ${file} downloaded!`);
        }
        await decryptAndSaveFiles();
        console.log(`✅ All Done!`);
    } catch (error) {
        console.error(`Error reading file or downloading data: ${error.message}`);
    }
    // console.log(`✅ DONE!`);
}
main().then(() => {
    process.exit();
});