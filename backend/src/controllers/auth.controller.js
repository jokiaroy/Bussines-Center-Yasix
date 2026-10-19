const authService = require('../services/auth.service');

const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        status: 'error',
        message: 'Email dan password wajib diisi.',
      });
    }

    const result = await authService.loginService(email, password);
    return res.status(200).json({
      status: 'success',
      message: 'Login berhasil.',
      data: result,
    });
  } catch (error) {
    return res.status(400).json({
      status: 'error',
      message: error.message,
    });
  }
};

const registerSiswa = async (req, res) => {
  try {
    const { nis, name, email, password } = req.body;

    if (!nis || !name || !email || !password) {
      return res.status(400).json({
        status: 'error',
        message: 'NIS, nama, email, dan password wajib diisi.',
      });
    }

    const result = await authService.registerSiswaService({ nis, name, email, password });
    return res.status(201).json({
      status: 'success',
      message: 'Pendaftaran siswa berhasil.',
      data: result,
    });
  } catch (error) {
    return res.status(400).json({
      status: 'error',
      message: error.message,
    });
  }
};

const getMe = async (req, res) => {
  return res.status(200).json({
    status: 'success',
    data: req.user,
  });
};

module.exports = {
  login,
  registerSiswa,
  getMe,
};