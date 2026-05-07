USE RikkeiClinicDB;
-- A 
-- Input : Mã bệnh nhân,Mã thuốc,ố lượng thuốc,Mã giảm giá
-- Output : Thông báo cho người dùng

-- B
DELIMITER //

CREATE PROCEDURE ProcessPrescription(IN p_patient_id INT,IN p_medicine_id INT,IN p_quantity INT,IN p_discount_code VARCHAR(50),OUT p_message VARCHAR(255))
BEGIN
    -- Biến cục bộ
    DECLARE v_price DECIMAL(18,2);
    DECLARE v_stock INT;
    DECLARE v_total DECIMAL(18,2);
    SELECT price, stock
    INTO v_price, v_stock
    FROM Medicines
    WHERE medicine_id = p_medicine_id;
    -- Kiểm tra tồn kho
    IF v_stock < p_quantity THEN
        SET p_message = 'Lỗi: Không đủ thuốc trong kho';
    ELSE
        -- Trừ số lượng thuốc trong kho
        UPDATE Medicines
        SET stock = stock - p_quantity
        WHERE medicine_id = p_medicine_id;
        -- Tính tiền
        SET v_total = p_quantity * v_price;
        -- Áp dụng mã giảm giá
        IF p_discount_code = 'NV-RIKKEI' THEN
            SET v_total = v_total * 0.5;
        END IF;
        -- Cộng vào công nợ 
        UPDATE Patient_Invoices
        SET total_due = total_due + v_total
        WHERE patient_id = p_patient_id;
        SET p_message = 'Thành công: Đã xử lý đơn thuốc';
    END IF;
END //
DELIMITER ;
CALL ProcessPrescription(1,1,2,'',@thongbao1);
SELECT @thongbao1;
CALL ProcessPrescription(2,1,4,'NV-RIKKEI',@thongbao2);
SELECT @thongbao2;
CALL ProcessPrescription(3,2,10,'',@thongbao3);
SELECT @thongbao3;
