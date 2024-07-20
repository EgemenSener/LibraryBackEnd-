package com.egemen.spring_boot_library.dao;

import com.egemen.spring_boot_library.entity.Checkout;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CheckoutRepository extends JpaRepository<Checkout, Long> {
    Checkout findByUserEmailAndAndBookId(String userEmail, Long bookId);
}
