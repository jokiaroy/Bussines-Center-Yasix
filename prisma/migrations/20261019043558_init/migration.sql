-- CreateTable
CREATE TABLE `users` (
    `id` VARCHAR(191) NOT NULL,
    `nis` VARCHAR(191) NULL,
    `name` VARCHAR(191) NOT NULL,
    `email` VARCHAR(191) NOT NULL,
    `password` VARCHAR(191) NOT NULL,
    `role` ENUM('ADMIN', 'KASIR', 'SISWA') NOT NULL DEFAULT 'SISWA',
    `qr_code_member` VARCHAR(191) NULL,
    `points` INTEGER NOT NULL DEFAULT 0,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,

    UNIQUE INDEX `users_nis_key`(`nis`),
    UNIQUE INDEX `users_email_key`(`email`),
    UNIQUE INDEX `users_qr_code_member_key`(`qr_code_member`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `categories` (
    `id` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `type` ENUM('ATK', 'JASA_PRINT') NOT NULL DEFAULT 'ATK',

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `products` (
    `id` VARCHAR(191) NOT NULL,
    `category_id` VARCHAR(191) NOT NULL,
    `barcode` VARCHAR(191) NULL,
    `name` VARCHAR(191) NOT NULL,
    `description` TEXT NULL,
    `hpp` DECIMAL(12, 2) NOT NULL,
    `margin` DECIMAL(5, 2) NOT NULL,
    `selling_price` DECIMAL(12, 2) NOT NULL,
    `stock` INTEGER NOT NULL DEFAULT 0,
    `min_stock` INTEGER NOT NULL DEFAULT 5,
    `image_url` VARCHAR(191) NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,

    UNIQUE INDEX `products_barcode_key`(`barcode`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `print_orders` (
    `id` VARCHAR(191) NOT NULL,
    `order_number` VARCHAR(191) NOT NULL,
    `student_id` VARCHAR(191) NOT NULL,
    `file_url` VARCHAR(191) NOT NULL,
    `file_name` VARCHAR(191) NOT NULL,
    `page_count` INTEGER NOT NULL,
    `color_type` ENUM('BW', 'COLOR') NOT NULL,
    `paper_size` VARCHAR(191) NOT NULL,
    `finishing` VARCHAR(191) NULL,
    `total_price` DECIMAL(12, 2) NOT NULL,
    `status` ENUM('PENDING', 'PROCESSING', 'READY', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'PENDING',
    `notes` TEXT NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,

    UNIQUE INDEX `print_orders_order_number_key`(`order_number`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `vouchers` (
    `id` VARCHAR(191) NOT NULL,
    `code` VARCHAR(191) NOT NULL,
    `discount_pct` DECIMAL(5, 2) NOT NULL,
    `max_discount` DECIMAL(12, 2) NULL,
    `min_purchase` DECIMAL(12, 2) NOT NULL DEFAULT 0,
    `valid_until` DATETIME(3) NOT NULL,
    `is_active` BOOLEAN NOT NULL DEFAULT true,

    UNIQUE INDEX `vouchers_code_key`(`code`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `transactions` (
    `id` VARCHAR(191) NOT NULL,
    `invoice_number` VARCHAR(191) NOT NULL,
    `cashier_id` VARCHAR(191) NOT NULL,
    `student_id` VARCHAR(191) NULL,
    `voucher_id` VARCHAR(191) NULL,
    `subtotal` DECIMAL(12, 2) NOT NULL,
    `discount_amount` DECIMAL(12, 2) NOT NULL DEFAULT 0,
    `total_amount` DECIMAL(12, 2) NOT NULL,
    `pay_amount` DECIMAL(12, 2) NOT NULL,
    `change_amount` DECIMAL(12, 2) NOT NULL,
    `payment_method` ENUM('CASH', 'QRIS') NOT NULL DEFAULT 'CASH',
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    UNIQUE INDEX `transactions_invoice_number_key`(`invoice_number`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `transaction_items` (
    `id` VARCHAR(191) NOT NULL,
    `transaction_id` VARCHAR(191) NOT NULL,
    `product_id` VARCHAR(191) NULL,
    `print_order_id` VARCHAR(191) NULL,
    `item_name` VARCHAR(191) NOT NULL,
    `price` DECIMAL(12, 2) NOT NULL,
    `quantity` INTEGER NOT NULL,
    `subtotal` DECIMAL(12, 2) NOT NULL,

    UNIQUE INDEX `transaction_items_print_order_id_key`(`print_order_id`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `cashier_shifts` (
    `id` VARCHAR(191) NOT NULL,
    `cashier_id` VARCHAR(191) NOT NULL,
    `start_cash` DECIMAL(12, 2) NOT NULL,
    `end_cash` DECIMAL(12, 2) NULL,
    `actual_cash` DECIMAL(12, 2) NULL,
    `difference` DECIMAL(12, 2) NULL,
    `start_time` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `end_time` DATETIME(3) NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- AddForeignKey
ALTER TABLE `products` ADD CONSTRAINT `products_category_id_fkey` FOREIGN KEY (`category_id`) REFERENCES `categories`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `print_orders` ADD CONSTRAINT `print_orders_student_id_fkey` FOREIGN KEY (`student_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `transactions` ADD CONSTRAINT `transactions_cashier_id_fkey` FOREIGN KEY (`cashier_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `transactions` ADD CONSTRAINT `transactions_student_id_fkey` FOREIGN KEY (`student_id`) REFERENCES `users`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `transactions` ADD CONSTRAINT `transactions_voucher_id_fkey` FOREIGN KEY (`voucher_id`) REFERENCES `vouchers`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `transaction_items` ADD CONSTRAINT `transaction_items_transaction_id_fkey` FOREIGN KEY (`transaction_id`) REFERENCES `transactions`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `transaction_items` ADD CONSTRAINT `transaction_items_product_id_fkey` FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `transaction_items` ADD CONSTRAINT `transaction_items_print_order_id_fkey` FOREIGN KEY (`print_order_id`) REFERENCES `print_orders`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `cashier_shifts` ADD CONSTRAINT `cashier_shifts_cashier_id_fkey` FOREIGN KEY (`cashier_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;
