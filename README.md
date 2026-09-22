# Análise de Extrato Bancário em R 📊

Projeto pessoal desenvolvido para analisar e visualizar gastos mensais a partir do extrato bancário exportado em formato `.ofx` (Itaú).

O objetivo principal foi automatizar a leitura do extrato financeiro, categorizar as transações por palavras-chave e gerar visualizações gráficas para facilitar o controle financeiro.

---

## 🛠️ Tecnologias e Pacotes Utilizados

- **Linguagem:** R
- **IDE:** RStudio
- **`tidyverse`**: Manipulação e limpeza dos dados
- **`ggplot2`**: Criação dos gráficos
- **`scales`**: Formatação dos eixos em moeda nacional (R$)
- **`stringr`**: Parsing de texto e buscas via Expressões Regulares (Regex)

---

## 🚀 Funcionalidades

- **Parser do arquivo OFX:** Leitura nativa do arquivo `.ofx` sem dependência de pacotes externos de terceiros.
- **Categorização Automática:** Classificação dos lançamentos por regra de negócios via `case_when` e regex (Alimentação, Transporte, Contas Fixas, Investimentos, etc.).
- **Visualizações Gráficas:**
  - Gráfico de Balanço Mensal (Entradas vs. Saídas)
  - Gráfico de Barras Horizontais com o detalhamento dos gastos por categoria

---

## 📈 Gráficos Gerados

Os gráficos são salvos automaticamente na pasta do projeto em alta resolução (`.png`):

1. **Balanço Mensal (`balanco_mensal.png`)**: Visão geral de receitas vs despesas.
2. **Gastos por Categoria (`gastos_por_categoria.png`)**: Ranking das categorias onde houve maior saída de recursos.

---
