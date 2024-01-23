const { Client } = require('pg');

// Konfigurasi koneksi ke PostgreSQL
const client = new Client({
    user: 'dteti',
    host: 'localhost',
    database: 'hospitals',
    password: 'postgresdteti',
    port: 5432,
});

// Fungsi untuk membaca semua data dari tabel
async function readAllData() {
    try {
        const result = await client.query('SELECT * FROM us_drug_overdose_death_rates');
        console.log('Semua Data:');
        console.log(result.rows);
    } catch (error) {
        console.error('Gagal membaca data:', error.message);
    }
}

// Fungsi untuk menambahkan data baru dengan nilai-nilai random
async function addRandomData() {
    try {
        // Data baru dengan nilai-nilai random
        const newData = {
            indicator: 'Drug overdose death rates',
            panel: 'All drug overdose deaths',
            panel_num: '0',
            unit: 'Deaths per 100,000 resident population, age-adjusted',
            unit_num: '1',
            stub_name: 'Total',
            stub_name_num: '0',
            stub_label: 'All persons',
            stub_label_num: '0.1',
            year: '1999',
            year_num: '1',
            age: 'All ages',
            age_num: '1.1',
            estimate: Math.random() * (100 - 1) + 1,
            flag: Math.random() < 0.5 ? 'A' : 'B',
        };

        const insertQuery = `
      INSERT INTO us_drug_overdose_death_rates
      (indicator, panel, panel_num, unit, unit_num, stub_name, stub_name_num, stub_label, stub_label_num, year, year_num, age, age_num, estimate, flag)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)
    `;

        const values = Object.values(newData);

        await client.query(insertQuery, values);

        console.log('Data baru dengan nilai-nilai random berhasil ditambahkan');
    } catch (error) {
        console.error('Gagal menambahkan data baru:', error.message);
    }
}

// Contoh penggunaan
async function main() {
    await client.connect();
    // Membaca semua data
    await readAllData();

    // Menambahkan data baru dengan nilai-nilai random
    await addRandomData();

    // Membaca semua data setelah penambahan data baru
    // await readAllData();

    await client.end();
}

// Panggil fungsi utama
main();