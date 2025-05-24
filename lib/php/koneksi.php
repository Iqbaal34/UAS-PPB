<?php
$host = "localhost"; // Ganti sesuai host MySQL Anda
$user = "root";           // Ganti sesuai user MySQL Anda
$pass = "";               // Ganti sesuai password MySQL Anda
$db   = "perpustakaaniqbal"; // Ganti sesuai nama database Anda

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die("Koneksi gagal: " . $conn->connect_error);
}
?>