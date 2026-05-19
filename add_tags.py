import requests
import time
import csv

USER_ID = "6201247"
ACCESS_TOKEN = "76c7ead743aef9a4915a021a9cd6b7ef8a1f5e49"

HEADERS = {
    "Authentication": f"bearer {ACCESS_TOKEN}",
    "User-Agent": "EoraScript (contato@eora.com.br)",
    "Content-Type": "application/json"
}

BASE_URL = f"https://api.nuvemshop.com.br/v1/{USER_ID}"

# =============================================
# CONFIGURAÇÃO: ajuste aqui antes de rodar
# =============================================

TAG_PARA_ADICIONAR = "minha-tag"  # <- troque pela tag desejada

# Caminho para o CSV exportado da Nuvemshop com os produtos que devem receber a tag
ARQUIVO_CSV = r"C:\Users\rcalmeida\Downloads\tiendanube-6201247-17787739273585742057275369013.csv"

# =============================================

def ler_handles_do_csv(caminho):
    handles = set()
    with open(caminho, encoding="latin-1") as f:
        reader = csv.DictReader(f, delimiter=";")
        for row in reader:
            handle = row.get("Identificador URL", "").strip()
            if handle:
                handles.add(handle)
    print(f"{len(handles)} produto(s) no CSV.\n")
    return handles

def get_all_products():
    products = []
    page = 1
    print("Buscando produtos na API...")
    while True:
        res = requests.get(
            f"{BASE_URL}/products",
            headers=HEADERS,
            params={"page": page, "per_page": 200}
        )
        if res.status_code != 200:
            print(f"Erro ao buscar produtos: {res.status_code} - {res.text}")
            break
        data = res.json()
        if not data:
            break
        products.extend(data)
        print(f"  Página {page}: {len(data)} produtos carregados")
        page += 1
        time.sleep(0.5)
    print(f"Total: {len(products)} produtos na loja.\n")
    return products

def add_tag_to_product(product):
    existing_tags = product.get("tags", "") or ""
    tags_list = [t.strip() for t in existing_tags.split(",") if t.strip()]

    if TAG_PARA_ADICIONAR in tags_list:
        print(f"  [{product['id']}] Já possui a tag. Pulando.")
        return

    tags_list.append(TAG_PARA_ADICIONAR)
    new_tags = ", ".join(tags_list)

    res = requests.put(
        f"{BASE_URL}/products/{product['id']}",
        headers=HEADERS,
        json={"tags": new_tags}
    )

    if res.status_code == 200:
        print(f"  [{product['id']}] Tag adicionada com sucesso.")
    else:
        print(f"  [{product['id']}] Erro: {res.status_code} - {res.text}")

    time.sleep(0.6)  # respeita rate limit da API

# =============================================

handles_do_csv = ler_handles_do_csv(ARQUIVO_CSV)
todos_produtos = get_all_products()

# Cruza os produtos da loja com os handles do CSV
selecionados = [p for p in todos_produtos if p.get("handle") in handles_do_csv]

print(f"{len(selecionados)} produto(s) encontrado(s) para receber a tag '{TAG_PARA_ADICIONAR}'.\n")

for p in selecionados:
    add_tag_to_product(p)

print("\nConcluído!")
