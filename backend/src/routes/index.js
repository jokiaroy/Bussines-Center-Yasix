const express = require('express');
const router = express.Router();
const prisma = require('../config/prisma');
const authRoutes = require('./auth.routes');

// Health check endpoint dengan pengecekan database otomatis
router.get('/health', async (req, res) => {
  try {
    // Jalankan query ringan untuk verifikasi koneksi ke MySQL Docker
    await prisma.$queryRaw`SELECT 1`;
    const totalUsers = await prisma.user.count();

    return res.status(200).json({
      status: 'success',
      message: 'Business Center API & Database MySQL Docker terhubung dengan lancar!',
      database: {
        status: 'CONNECTED',
        totalUsers,
      },
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    return res.status(500).json({
      status: 'error',
      message: 'Gagal terhubung ke Database MySQL!',
      database: {
        status: 'DISCONNECTED',
        error: error.message,
      },
      timestamp: new Date().toISOString(),
    });
  }
});

// Modul Auth
router.use('/auth', authRoutes);

module.exports = router;