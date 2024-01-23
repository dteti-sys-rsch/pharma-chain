const mongoose = require('mongoose');

// Fungsi untuk menghubungkan ke MongoDB
async function connectToMongoDB() {
    try {
        const mongoURL = 'mongodb://dteti:mongodteti@localhost:27017/healthinsurance?authSource=admin';
        console.log('Menghubungkan ke MongoDB localhost:27017/healthinsurance...');
        await mongoose.connect(mongoURL);
        console.log('Berhasil terhubung ke MongoDB: healthinsurance');
    } catch (error) {
        console.error('Gagal terhubung ke MongoDB:', error.message);
        process.exit(1);
    }
}

// Fungsi untuk memutus koneksi dari MongoDB
async function disconnectFromMongoDB() {
    try {
        await mongoose.disconnect();
        console.log('Berhasil memutus koneksi dari MongoDB');
    } catch (error) {
        console.error('Gagal memutus koneksi dari MongoDB:', error.message);
    }
}
// Membuat skema (schema) untuk koleksi pasien
const patientSchema = new mongoose.Schema({
    age: Number,
    sex: String,
    bmi: Number,
    children: Number,
    smoker: String,
    region: String,
    charges: Number,
});

// Membuat model pasien berdasarkan skema
const Patient = mongoose.model('Patient', patientSchema, 'US-health-insurance');

// Fungsi untuk membaca semua data pasien
async function readPatients() {
    try {
        const patients = await Patient.find().sort({ _id: -1 }).limit(10);;
        console.log('Data Pasien:');
        console.log(patients);
    } catch (error) {
        console.error('Gagal membaca data pasien:', error.message);
    }
}

// Fungsi untuk menambahkan data pasien dengan nilai-nilai yang di-random
async function addRandomPatient() {
    try {
        // Data pasien dengan nilai-nilai yang di-random
        const newPatientData = {
            age: Math.floor(Math.random() * 100) + 1, // Random nilai 1-100
            sex: Math.random() < 0.5 ? 'male' : 'female', // Random pilih male atau female
            bmi: Math.random() * (40 - 18) + 18, // Random nilai 18-40 untuk BMI
            children: Math.floor(Math.random() * 11), // Random nilai 0-10 untuk children
            smoker: Math.random() < 0.5 ? 'yes' : 'no', // Random pilih yes atau no untuk smoker
            region: ['northeast', 'northwest', 'southeast', 'southwest'][Math.floor(Math.random() * 4)], // Random pilih salah satu region
            charges: Math.random() * (100000 - 100) + 100, // Random nilai 100-100000 untuk charges
        };

        // Membuat instance objek Patient
        const newPatient = new Patient(newPatientData);

        // Menyimpan data pasien ke MongoDB
        await newPatient.save();
        console.log('Data pasien dengan nilai-nilai random berhasil ditambahkan');
    } catch (error) {
        console.error('Gagal menambahkan data pasien:', error.message);
    }
}
async function main() {
    // Menghubungkan ke MongoDB
    await connectToMongoDB();

    // Membaca data pasien
    await readPatients();

    // Menambahkan data pasien
    await addRandomPatient();

    // Membaca data pasien setelah penambahan
    await readPatients();

    // Memutus koneksi dari MongoDB setelah selesai
    await disconnectFromMongoDB();
}

main();