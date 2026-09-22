library(tidyverse)
library(ggplot2)
library(scales)

linhas <- readLines("extrato.ofx", warn = FALSE)

datas_raw <- linhas[str_detect(linhas, "<DTPOSTED>")] %>% 
  str_extract("\\d{8}")

valores_raw <- linhas[str_detect(linhas, "<TRNAMT>")] %>% 
  str_extract("-?\\d+\\.\\d+|-?\\d+")

descricoes_raw <- linhas[str_detect(linhas, "<MEMO>")] %>% 
  str_remove_all("<MEMO>") %>% 
  str_trim()

# Criação da Tabela e Categorização
extrato <- tibble(
  Data = as.Date(datas_raw, format = "%Y%m%d"),
  Valor = as.numeric(valores_raw),
  Descricao = descricoes_raw
) %>% 
  mutate(
    Tipo = if_else(Valor > 0, "Receita", "Despesa"),
    Valor_Abs = abs(Valor),
    Categoria = case_when(
      str_detect(toupper(Descricao), "IFOOD|RESTAURANTE|PADARIA|LANCHONETE|MERCADO|SUPERMERCADO|ATACADAO|CARREFOUR|PAO DE ACUCAR") ~ "Alimentação e Mercado",
      str_detect(toupper(Descricao), "UBER|99APP|POSTO|SHELL|IPIRANGA|BR|AUTO POSTO|ESTAC|PEDAGIO") ~ "Transporte",
      str_detect(toupper(Descricao), "PIX TRANSF|PIX ENVIADO|TEF|TED") & str_detect(toupper(Descricao), "FELIPE") ~ "Investimentos",
      str_detect(toupper(Descricao), "PIX TRANSF|PIX ENVIADO|TEF|TED") & Valor < 0 ~ "Transferências Enviadas",
      str_detect(toupper(Descricao), "PIX RECEBIDO|SALARIO|PROVENTOS|RENDIMENTO") & Valor > 0 ~ "Renda / Entradas",
      str_detect(toupper(Descricao), "FATURA|PAGTO ELETRON COBRANCA|PAG COMPRA CARTAO|TARC|CARTAO") ~ "Cartão de Crédito",
      str_detect(toupper(Descricao), "NETFLIX|SPOTIFY|PRIME VIDEO|STEAM|GOOGLE|APPLE|DISNEY|HBO|YOUTUBE") ~ "Assinaturas e Lazer",
      str_detect(toupper(Descricao), "CONDOMINIO|LUZ|ENEL|ENERGIA|SABESP|AGUA|CLARO|VIVO|TIM|ALUGUEL|DA ") ~ "Contas Fixas",
      str_detect(toupper(Descricao), "SAQUE|TARIFA|TAR |MENSALIDADE") ~ "Tarifas / Saques",
      TRUE ~ "Outros"
    )
  )

# Balanço Mensal (Receitas vs Despesas)
resumo_geral <- extrato %>%
  group_by(Tipo) %>%
  summarise(Total = sum(Valor_Abs))

ggplot(resumo_geral, aes(x = Tipo, y = Total, fill = Tipo)) +
  geom_col(width = 0.4, show.legend = FALSE) +
  geom_text(aes(label = dollar(Total, prefix = "R$ ", big.mark = ".", decimal.mark = ",")), 
            vjust = -0.5, fontface = "bold") +
  scale_y_continuous(labels = dollar_format(prefix = "R$ ", big.mark = ".", decimal.mark = ","),
                     expand = expansion(mult = c(0, 0.15))) +
  scale_fill_manual(values = c("Despesa" = "#e74c3c", "Receita" = "#2ecc71")) +
  labs(
    title = "Balanço Mensal: Receitas vs Despesas",
    subtitle = "Extrato Itaú",
    x = NULL,
    y = "Valor Total (R$)"
  ) +
  theme_minimal()

ggsave("balanco_mensal.png", width = 8, height = 5, dpi = 300)

# Detalhamento de Gastos por Categoria
despesas_categoria <- extrato %>%
  filter(Tipo == "Despesa") %>%
  group_by(Categoria) %>%
  summarise(Total = sum(Valor_Abs))

ggplot(despesas_categoria, aes(x = reorder(Categoria, Total), y = Total, fill = Categoria)) +
  geom_col(show.legend = FALSE) +
  coord_flip() + # Deixa as barras na horizontal para facilitar a leitura
  geom_text(aes(label = dollar(Total, prefix = "R$ ", big.mark = ".", decimal.mark = ",")), 
            hjust = -0.1, size = 3.5) +
  scale_y_continuous(labels = dollar_format(prefix = "R$ ", big.mark = ".", decimal.mark = ","),
                     expand = expansion(mult = c(0, 0.2))) +
  labs(
    title = "Distribuição de Gastos por Categoria",
    x = NULL,
    y = "Total Gasto (R$)"
  ) +
  theme_minimal()

ggsave("gastos_por_categoria.png", width = 9, height = 6, dpi = 300)
