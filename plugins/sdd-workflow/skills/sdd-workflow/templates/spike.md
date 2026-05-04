# Spike Técnico — [Nome do Risco]

> Spike é fase **opcional** entre Spec.Design e Build.Tasks. Entra quando o Design identificou risco técnico (integração externa nova, lib desconhecida, dependência crítica). Objetivo: validar hipótese antes de quebrar tasks. Box temporal sugerido: 1-3 dias.
>
> **Heurísticas relevantes**: H4 (anti-abstração prematura — 3+ casos antes de abstrair: o spike pode revelar que a abstração planejada é prematura), H6 (defensividade sobre dependências externas — spike típico envolve API externa), H9 (TDD canônico universal — testes do spike seguem Red/Green/Refactor mesmo se em prova de conceito). Ver `references/heuristicas.md`.

## 1. Risco técnico identificado

[O que faz esse spike necessário? Qual incerteza estamos resolvendo? Vir do Spec.Design seção 8.]

## 2. Hipóteses

### 2.1 Hipótese principal

[Frase clara: "Acreditamos que X funciona porque Y"]

### 2.2 Hipóteses alternativas

[Outras possibilidades caso a principal não se sustente]

## 3. Critérios de sucesso

[Como saberemos que a hipótese se confirmou? Métrica/comportamento concreto.]

- [ ] [Critério 1]
- [ ] [Critério 2]

## 4. Investigação

### 4.1 Setup mínimo

[Código/configuração mínima pra testar a hipótese. NÃO é production code — é prova de conceito.]

```
[código de prova]
```

### 4.2 Resultados

[O que aconteceu na prática? Logs, screenshots, medições.]

### 4.3 Surpresas

[Algo inesperado? Pode invalidar a hipótese ou apontar caminho diferente.]

## 5. Decisão

- [ ] **Hipótese confirmada** — seguir com a stack/abordagem original. Build.Tasks pode ser quebrada baseado no Design.
- [ ] **Hipótese parcialmente confirmada** — pivot menor: [descrever mudança].
- [ ] **Hipótese não confirmada** — pivot maior: [stack alternativa, abordagem diferente]. Atualizar Constitution e Spec.Design antes de avançar.

## 6. Próximo passo

→ Build.Tasks (com decisão acima absorvida)

## 7. Aprendizados pra registrar na Constitution

[Conhecimento técnico adquirido que vale ser registrado nas decisões da constitution]

- [Aprendizado 1]
- [Aprendizado 2]
