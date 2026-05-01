# Requirements — [Nome do Projeto]

> **Formato**: EARS (Easy Approach to Requirements Syntax). Ver `references/linguagens-especificacao.md` da skill SDD pros 5 padrões. Cada requirement é uma frase precisa, sem ambiguidade.

## 1. Visão geral do sistema

[Resumo do que o sistema faz — 2-3 frases]

## 2. Usuários e perfis de acesso

| Perfil | Permissões | Exemplos de ações |
|---|---|---|
| [perfil] | [permissões] | [ações] |

## 3. Dados de referência

[Lista de documentos reais analisados — planilhas, PDFs, processos manuais. Linkar paths/URLs. **Princípio inviolável 1**: todos os dados de seed/teste vêm desses documentos, nunca fictícios.]

- [Documento 1]: [path] — [resumo do conteúdo]
- [Documento 2]: [path] — [resumo do conteúdo]

## 4. Módulos do sistema

### 4.1 [Nome do Módulo]

**Propósito**: [1 frase]

**Requirements (formato EARS)**:

```ears
Ubiquitous:
  O <sujeito> deve <comportamento>.

State-driven:
  Enquanto <estado>, o <sujeito> deve <comportamento>.

Event-driven:
  Quando <evento>, o <sujeito> deve <comportamento>.

Optional Feature:
  Onde <feature presente>, o <sujeito> deve <comportamento>.

Unwanted Behavior:
  Se <condição>, então o <sujeito> não deve <comportamento>.
```

**Regras de negócio críticas** (com exemplos de dados reais):

- [Regra 1] — exemplo: [valor da planilha X linha Y]
- [Regra 2] — exemplo: [...]

### 4.2 [Próximo módulo]

[...]

## 5. Requisitos não-funcionais

(Conforme tier — ver `references/tiers.md` da skill SDD)

- Performance: [...]
- Segurança: [...]
- Acessibilidade: [...]
- [...]

## 6. Dados iniciais (seed)

**Princípio inviolável**: NUNCA dados fictícios. Sempre extrair dos documentos de referência (seção 3).

- [Tabela X]: extraída de [documento Y]
- [...]

## 7. Fora do escopo V1

[O que NÃO está no V1 — defere pra V2 ou descarta]

- [...]
