const crypto = require('crypto');
const fs = require('fs/promises');
const path = require('path');

const inputOriginFolder = 'input-files';
const key = 'abcdefghijklmnopqrstuvwxyz';


// Fungsi untuk enkripsi data
const encrypt = async (data) => {
    const cipher = crypto.createCipher('aes-256-cbc', key);
    let encryptedData = cipher.update(data, 'base64', 'base64');
    encryptedData += cipher.final('base64');
    return encryptedData;
};

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
// Fungsi untuk membaca dan mengenkripsi file
const sendToHelia = async (node) => {
    const { base32 } = await import("multiformats/bases/base32")
    try {
        // Baca semua file di dalam folder input-files/origin
        const files = await fs.readdir(inputOriginFolder);
        let file_metadata = [];
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

            // upload ke Helia
            const cid = await uploadToHelia(node, encryptedData);
            console.log(`✅ File ${file} uploaded!`);
            console.log(cid.toString(base32))
            file_metadata.push({ file, cid: cid.toString(base32) });
        }
        // simpan informasi nama file dan cid
        const jsonData = JSON.stringify(file_metadata, null, 2);
        const path_metadata = path.join('.', `metadata.txt`);
        await fs.writeFile(path_metadata, jsonData, 'utf-8');
        console.log(`✅ File metadata created!`);
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

    await sendToHelia(node);
    console.log(`✅ DONE!`);
}
main().then(() => process.exit(0))