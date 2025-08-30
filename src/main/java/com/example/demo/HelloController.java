package com.example.demo;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.info.BuildProperties;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;

@RestController
public class HelloController {

    @Autowired(required = false)
    private BuildProperties buildProperties;


    @GetMapping("/hello")
    public String hello() {
        return "Hello, World!";
    }

    @GetMapping("/")
    public String getVersion() {
        String version = "N/A";
        if (buildProperties != null) {
            version = buildProperties.getVersion();
        }
        return "Aplikasi berjalan pada versi: " + version;
    }
}
