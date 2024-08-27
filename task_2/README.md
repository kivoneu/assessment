# Infrastruktura aplikacji webowej na Google Cloud Platform

Ten projekt Terraform tworzy infrastrukturę dla skalowalnej aplikacji webowej na Google Cloud Platform (GCP).

## Komponenty

- Sieć VPC z podsiecią
- Grupa instancji zarządzanych dla serwerów webowych
- Load Balancer
- Instancja Cloud SQL (PostgreSQL)
- Bucket Google Cloud Storage

## Wymagania

- Terraform (wersja >= 0.12)
- Konto Google Cloud Platform
- Aktywowany projekt GCP
- Zainstalowane i skonfigurowane Google Cloud SDK

## Użycie

1. Sklonuj to repozytorium:
   ```
   git clone <URL_REPOZYTORIUM>
   cd <NAZWA_KATALOGU>
   ```

2. Utwórz plik `terraform.tfvars` i dodaj swoje zmienne:
   ```
   project_id = "twoj-projekt-id"
   region     = "us-central1"  # lub inny wybrany region
   ```

3. Zainicjuj Terraform:
   ```
   terraform init
   ```

4. Zaplanuj wdrożenie:
   ```
   terraform plan
   ```

5. Zastosuj konfigurację:
   ```
   terraform apply
   ```

6. Po zakończeniu wdrażania, wyświetlone zostaną ważne informacje wyjściowe, takie jak adres IP Load Balancera.

## Czyszczenie

Aby usunąć utworzoną infrastrukturę:

```
terraform destroy
```

## Uwagi

- Pamiętaj o zabezpieczeniu dostępu do bazy danych i bucketu storage.
- Rozważ użycie zmiennych środowiskowych lub innego bezpiecznego sposobu przechowywania wrażliwych danych.
- Ta konfiguracja jest przykładowa i może wymagać dostosowania do konkretnych potrzeb produkcyjnych.
