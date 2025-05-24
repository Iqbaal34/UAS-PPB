<?php
header('Content-Type: application/json');
require_once 'koneksi.php';

$username = $_POST['username'] ?? '';
$password = $_POST['password'] ?? '';

// Jika password di database di-hash MD5, aktifkan baris berikut:
// $password = md5($password);

$stmt = $conn->prepare("SELECT * FROM akun WHERE username = ? AND password = ?");
$stmt->bind_param("ss", $username, $password);
$stmt->execute();
$result = $stmt->get_result();

if ($row = $result->fetch_assoc()) {
    if ($row['status'] === 'aktif') {
        echo json_encode([
            "success" => true,
            "status" => $row['status'],
            "nama" => $row['identitasnama']
        ]);
    } else {
        echo json_encode([
            "success" => false,
            "message" => "Akun belum dikonfirmasi oleh admin."
        ]);
    }
} else {
    echo json_encode([
        "success" => false,
        "message" => "Username atau password salah."
    ]);
}
$conn->close();
?>