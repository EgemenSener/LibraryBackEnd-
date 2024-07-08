package com.egemen.spring_boot_library.entity;

import lombok.Data;

import javax.persistence.*;

@Entity
@Data
public class Book {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;

    private String author;

    private String description;

    private int copies;

    private int copiesAvailable;

    private String category;

    private String img;
}
