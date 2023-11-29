const crypto = require('crypto');
const fs = require('fs/promises');
const path = require('path');

const inputOriginFolder = 'input-files';
const inputEncryptedFolder = 'output-files/outcomes';
const outputDecryptedFolder = 'output-files/decrypted';
const key = 'abcdefghijklmnopqrstuvwxyz';

// Fungsi untuk enkripsi data
const encrypt = async (data) => {
    const cipher = crypto.createCipher('aes-256-cbc', key);
    let encryptedData = cipher.update(data, 'base64', 'base64');
    encryptedData += cipher.final('base64');
    return encryptedData;
};
// Fungsi untuk dekripsi data
const decrypt = (data) => {
    const decipher = crypto.createDecipher('aes-256-cbc', key);
    let decryptedData = decipher.update(data, 'base64', 'base64');
    decryptedData += decipher.final('base64');
    return decryptedData;
};
// Fungsi untuk upload ke IPFS
const uploadToHelia = async (node, fileData) => {
    const { unixfs } = await import('@helia/unixfs');
    // Create a Helia node
    const fs_unixfs = await unixfs(node);
    // Print out our node's PeerId
    console.log('PeerID Uploader:', node.libp2p.peerId.toString());
    const encoder = new TextEncoder();
    const cid = await fs_unixfs.addBytes(encoder.encode(fileData), node.blockstore);
    return cid;
}
// Fungsi untuk download dari IPFS
const downloadFromHelia = async (node, cid, fileData) => {
    const { unixfs } = await import('@helia/unixfs');
    console.log(`Downloading file with CID ${cid} on Node B...`);
    // Print out our node's PeerId
    console.log('PeerID Downloader:', node.libp2p.peerId.toString());
    // Create a Helia node
    const fs_unixfs = await unixfs(node);
    const decoder = new TextDecoder();
    let text = ''

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
// Fungsi untuk membaca file asli dan mengenkripsi file
const handleTransfer = async (node1, node2) => {
    try {
        // Baca semua file di dalam folder input-files/origin
        const files = await fs.readdir(inputOriginFolder);

        // Loop melalui setiap file
        for (const file of files) {
            const filePath = path.join(inputOriginFolder, file);
            // Baca isi file
            const fileData = await fs.readFile(filePath);

            // Convert file menjadi base64
            const base64Data = fileData.toString('base64');

            // Enkripsi base64 data
            let encryptedData;
            try {
                encryptedData = await encrypt(base64Data);
                console.log(`✅ File ${file} encrypted!`);
            } catch (err) {
                throw new Error(`Encryption error: ${err.message}`);
            }

            // upload ke Helia dari node 1
            const cid = await uploadToHelia(node1, encryptedData);
            console.log(`✅ File ${file} uploaded!`);

            // download dari helia pakai node 2
            await downloadFromHelia(node2, cid, file);
            console.log(`✅ File ${file} downloaded!`);
            // proses dekripsi dan simpan file yang sudah didekripsi
            await decryptAndSaveFiles();
            console.log(`✅ ALL DONE!`);
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
    const node1 = await createNode()
    const node2 = await createNode()

    // connect them together
    const multiaddrs = node2.libp2p.getMultiaddrs()
    await node1.libp2p.dial(multiaddrs[0])
    console.log(multiaddrs);

    // menjalankan proses enkripsi->upload->download->dekripsi
    await handleTransfer(node1, node2);
}
main().then(() => process.exit());