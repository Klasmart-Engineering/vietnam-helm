resource "google_kms_key_ring" "cluster" {
  name     = "cluster-keyring"
  location = var.region
}

resource "google_kms_crypto_key" "cluster" {
  name            = "cluster-key"
  purpose         = "ENCRYPT_DECRYPT"
  key_ring        = google_kms_key_ring.cluster.id
  rotation_period = "100000s"
}

resource "google_kms_crypto_key_iam_binding" "cluster" {
  crypto_key_id = google_kms_crypto_key.cluster.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  members = [
    "serviceAccount:${google_service_account.cluster.email}",
    "serviceAccount:service-${data.google_project.project.number}@container-engine-robot.iam.gserviceaccount.com"
  ]
}