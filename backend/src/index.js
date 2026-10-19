require("dotenv").config();
const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const morgan = require("morgan");
const rateLimit = require("express-rate-limit");
const path = require("path");
const { PrismaClient } = require("@prisma/client");

const prisma = new PrismaClient();
const app = express();
const PORT = process.env.PORT || 5000;

// 1. Security & CORS Configuration
app.use(helmet());
app.use(
  cors({
    origin: process.env.CLIENT_URL || "http://localhost:5173",
    credentials: true,
  }),
);

// 2. Rate Limiter for API Protection
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 300,
  message: {
    status: "error",
    message: "Terlalu banyak permintaan dari IP ini, silakan coba lagi nanti.",
  },
});
app.use("/api", limiter);

// 3. Body Parsers & Request Logging
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan("dev"));

// 4. Static File Serving (Uploads Directory)
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

// 5. Health Check & Diagnostics Endpoints
app.get("/", (req, res) => {
  res.json({
    status: "online",
    system: "Business Center SMK Yadika 6 API",
    environment: process.env.NODE_ENV || "development",
    timestamp: new Date().toISOString(),
  });
});

app.get("/api/v1/health", async (req, res) => {
  try {
    await prisma.$queryRaw`SELECT 1`;
    res.json({
      status: "success",
      database: "connected",
      uptime: process.uptime(),
    });
  } catch (error) {
    res.status(500).json({
      status: "error",
      database: "disconnected",
      error: error.message,
    });
  }
});

// 6. API Route Router Fallback
app.use("/api/v1", (req, res, next) => {
  try {
    const router = require("./src/routes");
    return router(req, res, next);
  } catch (err) {
    if (err.code === "MODULE_NOT_FOUND") {
      return res.json({
        status: "success",
        message: "API v1 Gateway Aktif. Router modul belum dimuat.",
      });
    }
    next(err);
  }
});

// 7. 404 Handler
app.use((req, res) => {
  res.status(404).json({
    status: "error",
    message: `Endpoint ${req.method} ${req.originalUrl} tidak ditemukan`,
  });
});

// 8. Global Error Handler
app.use((err, req, res, next) => {
  console.error("[ERROR HANDLER]:", err.stack || err.message);
  res.status(err.statusCode || 500).json({
    status: "error",
    message: err.message || "Internal Server Error",
  });
});

// 9. Server Initialization
const server = app.listen(PORT, async () => {
  console.log("==================================================");
  console.log(`🚀 Server running on http://localhost:${PORT}`);
  try {
    await prisma.$connect();
    console.log("🗄️  Database MySQL Docker connected via Prisma");
  } catch (error) {
    console.error("❌ Database connection failed:", error.message);
  }
  console.log("==================================================");
});

// 10. Graceful Shutdown
process.on("SIGINT", async () => {
  console.log("\nShutting down server gracefully...");
  await prisma.$disconnect();
  server.close(() => {
    console.log("Server process terminated.");
    process.exit(0);
  });
});
