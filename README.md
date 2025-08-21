# Projekt: Mikroserwis pod Obserwacją

Prosty projekt demonstrujący pełny cykl życia aplikacji w chmurze z wykorzystaniem nowoczesnych narzędzi DevOps. Aplikacja webowa w języku Python jest automatycznie wdrażana na maszynie wirtualnej w **Google Cloud Platform (GCP)**, a jej działanie jest monitorowane w czasie rzeczywistym za pomocą **Prometheusa** i **Grafany**.

Celem projektu jest praktyczne przećwiczenie i zrozumienie, jak poszczególne technologie łączą się ze sobą, tworząc spójny i zautomatyzowany proces wdrożeniowy.

## Stos Technologiczny 🛠️

* **Infrastruktura jako Kod (IaC):** Terraform
* **Dostawca Chmury:** Google Cloud Platform (GCP)
* **Konteneryzacja:** Docker
* **Orkiestracja na VM:** Docker Compose
* **Monitoring (metryki):** Prometheus
* **Monitoring (wizualizacja):** Grafana
* **Kontrola Wersji:** Git / GitHub

## Architektura

Architektura jest prosta i opiera się na jednej maszynie wirtualnej w usłudze **GCP Compute Engine**, której konfiguracja (sieć, firewall, typ maszyny) jest w pełni zarządzana przez **Terraform**.

Na tej maszynie uruchamiane są trzy kontenery zarządzane przez **Docker Compose**:
1. `webapp`: Aplikacja w Pythonie (Flask), która obsługuje ruch i wystawia metrykę `http_requests_total`.
2. `prometheus`: Serwer monitoringu, który cyklicznie pobiera metryki z punktu końcowego `/metrics` naszej aplikacji.
3. `grafana`: Narzędzie do wizualizacji, które łączy się z Prometheusem i wyświetla zebrane dane na wykresach.

## Jak uruchomić?

### 1. Konfiguracja Lokalna

Przed rozpoczęciem upewnij się, że masz zainstalowane Terraform, Google Cloud SDK i Docker, a następnie zaloguj się do swojego konta Google:

```bash
gcloud auth login
gcloud auth application-default login
```

### 2. Stworzenie Infrastruktury

W głównym folderze projektu uruchom Terraform, aby stworzyć maszynę wirtualną:

```bash
terraform init
terraform apply
```

### 3. Budowanie i Wysłanie Obrazu Docker

Zbuduj obraz aplikacji i wyślij go do Google Artifact Registry:

```bash
# Uwierzytelnij Dockera
gcloud auth configure-docker europe-central2-docker.pkg.dev

# Zbuduj i wypchnij obraz
docker build -t europe-central2-docker.pkg.dev/<YOUR_PROJECT_ID>/my-repo/moja-aplikacja:v1 .
docker push europe-central2-docker.pkg.dev/<YOUR_PROJECT_ID>/my-repo/moja-aplikacja:v1
```

### 4. Wdrożenie na Serwerze

Połącz się z nowo utworzoną maszyną i uruchom kontenery:

```bash
# Połącz się z maszyną
gcloud compute ssh devops-server --zone=europe-central2-a

# Sklonuj repozytorium
git clone https://github.com/<TWOJA_NAZWA>/<NAZWA_REPO>.git

# Wejdź do folderu i uruchom aplikację
cd <NAZWA_REPO>
sudo docker-compose up -d
```

## Dostęp do Usług

Po poprawnym wdrożeniu, usługi są dostępne pod publicznym adresem IP maszyny wirtualnej:

* **Aplikacja Webowa:** `http://<IP_MASZYNY>:8080`
* **Prometheus:** `http://<IP_MASZYNY>:9090`
* **Grafana:** `http://<IP_MASZYNY>:3000` (login: `admin`, hasło: `admin`)

## Sprzątanie

Aby usunąć całą infrastrukturę stworzoną w GCP i uniknąć kosztów, wykonaj komendę na swoim **lokalnym komputerze**:

```bash
terraform destroy
```