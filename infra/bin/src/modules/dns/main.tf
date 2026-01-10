resource "google_dns_managed_zone" "this" {
  name       = "${var.service_name}-zone"
  dns_name   = "${var.domain}."
  visibility = "public"

  labels = {
    name = "${var.service_name}-zone"
  }
}

# ドメインの所有者を証明する
resource "google_dns_record_set" "verification" {
  name         = "${var.domain}."
  managed_zone = google_dns_managed_zone.this.name
  type         = "TXT"
  ttl          = 300
  rrdatas      = ["${var.cert_txt_record}"]
}

# サブドメインの場合はCNAMEレコードを生成
resource "google_dns_record_set" "default_WWW" {
  count        = var.is_apex_domain ? 0 : 1
  name         = "${var.domain}."
  type         = "CNAME"
  ttl          = 3600
  managed_zone = google_dns_managed_zone.this.name
  rrdatas      = var.dns_record_WWW
}

# apex domainの場合はAレコードを生成
resource "google_dns_record_set" "default_A" {
  count        = var.is_apex_domain ? 1 : 0
  managed_zone = google_dns_managed_zone.this.name
  name         = "${var.domain}."
  type         = "A"
  ttl          = 3600
  rrdatas      = var.dns_records_A
}

# apex domainの場合はAAAAレコードを生成
resource "google_dns_record_set" "default_AAAA" {
  count        = var.is_apex_domain ? 1 : 0
  managed_zone = google_dns_managed_zone.this.name
  name         = "${var.domain}."
  type         = "AAAA"
  ttl          = 3600
  rrdatas      = var.dns_records_AAAA
}
