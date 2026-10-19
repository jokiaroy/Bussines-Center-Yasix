const express = require('express');
const { PrismaClient } = require('@prisma/client');

const router = express.Router();
const prisma = new PrismaClient();

// Endpoint Health Check + Cek Database
router.get('/health', async (req, res) => {
  try {
    // Mencoba melakukan tes query sederhana ke database
    await prisma.$queryRaw`SELECT 1`;
    
    // Mengambil jumlah user untuk memastikan data seed masuk
    const userCount = await prisma.user.count();

    res.status(200).json({
      status: 'success',
      message: 'Server Express & Database MySQL Docker TERHUBUNG!',
      database: {
        status: 'Connected',
        totalUsers: userCount,
      },
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Gagal terhubung ke Database MySQL!',
      database: 'Disconnected',
      error: error.message,
    });
  }
});

module.exports = router;