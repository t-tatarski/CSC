<?php
// Konfiguracja
$uploadDir = 'uploads/';
$adminEmail = 'twojemail@domena.pl';
$adminName  = 'Obsługa Zleceń';

// sprawdzenie czy katalog istnieje
if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0777, true);
}

// Walidacja danych
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $name    = htmlspecialchars($_POST['name']);
    $email   = filter_var($_POST['email'], FILTER_VALIDATE_EMAIL);
    $message = htmlspecialchars($_POST['message']);

    if (!$email) {
        die('Nieprawidłowy adres e-mail.');
    }

    // Obsługa pliku
    if (isset($_FILES['file']) && $_FILES['file']['error'] === UPLOAD_ERR_OK) {
        $filename = basename($_FILES['file']['name']);
        $targetFile = $uploadDir . time() . "_" . $filename;

        if (move_uploaded_file($_FILES['file']['tmp_name'], $targetFile)) {
            // E-mail do administratora
            $subjectAdmin = "Nowe zlecenie od $name";
            $bodyAdmin = "Imię: $name\nE-mail: $email\nOpis:\n$message\nPlik: $targetFile";
            mail($adminEmail, $subjectAdmin, $bodyAdmin, "From: no-reply@twojadomena.pl");

            // Potwierdzenie dla klienta
            $subjectClient = "Potwierdzenie otrzymania zlecenia";
            $bodyClient = "Dziękujemy za przesłanie zlecenia!\n\n"
                        . "Otrzymaliśmy następujące dane:\n"
                        . "Imię i nazwisko: $name\n"
                        . "Opis zlecenia: $message\n\n"
                        . "Skontaktujemy się z Tobą wkrótce.\n\n"
                        . "Pozdrawiamy,\n$adminName";

            mail($email, $subjectClient, $bodyClient, "From: $adminEmail");

            echo "Dziękujemy! Twoje zlecenie zostało przesłane, a potwierdzenie wysłane na e-mail.";
        } else {
            echo "Wystąpił błąd podczas zapisywania pliku.";
        }
    } else {
        echo "Nie załączono pliku lub wystąpił błąd.";
    }
} else {
    echo "Nieprawidłowe żądanie.";
}
?>
