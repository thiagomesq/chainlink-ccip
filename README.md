# Chainlink CCIP Fundamentals with Foundry

## Quickstart

Follow the steps below to initialize this project after cloning the repository:

1.  Clone the repository:
    ```bash
    git clone https://github.com/your-username/chainlink-ccip-foundry.git
    cd chainlink-ccip-foundry
    ```

2.  Install dependencies:
    ```bash
    make install
    ```

3.  Compile the contracts:
    ```bash
    make build
    ```

4.  Run the tests:
    ```bash
    make test
    ```

5.  (Optional) Set up environment variables in a `.env` file for blockchain network integration (e.g., `SEPOLIA_RPC_URL`, `ACCOUNT`, `ETHERSCAN_API_KEY`).

## Summary

This project provides practical examples of how to implement **Chainlink's Cross-Chain Interoperability Protocol (CCIP)** using the Foundry framework. It explores two fundamental patterns: **Cross-Chain Token Transfers** and **Cross-Chain Token Transfers with Function Calls (Arbitrary Messaging)**, demonstrating how to build applications that can securely communicate and transfer value between different blockchains.

## Description

### Motivation
The purpose of this project is to offer clear and functional examples for developers starting with Chainlink CCIP. It covers the essential patterns for creating "CCIP-enabled" applications, allowing for secure and reliable interactions across multiple blockchain networks.

### Tools and Technologies
- **Foundry**: A framework for developing, testing, and deploying smart contracts.
- **Solidity**: The programming language for smart contracts.
- **Chainlink CCIP**: For secure cross-chain communication, token transfers, and arbitrary messaging.
- **OpenZeppelin Contracts**: For secure and standard contract implementations.

### Project Structure
The project is organized as follows:
- `src/`: Contains the smart contracts:
    - `CCIPTokenSender.sol`: A basic contract demonstrating how to send ERC20 tokens to a receiver on a different blockchain.
    - `Sender.sol`: An advanced contract that sends tokens and an arbitrary message (a function call) to be executed on a target contract on the destination chain.
    - `Receiver.sol`: The counterpart to `Sender.sol`. It receives the tokens and the message, then executes the specified function call on the target contract.
    - `Vault.sol`: An example target contract on the destination chain. The `Receiver` calls its `deposit` function.
    - `chainlink-local/`: Contracts for local testing using `CCIPLocalSimulator`.
- `script/`: Scripts for deploying the contracts.
- `test/`: Contains test scripts to validate the functionality of the contracts.
- `foundry.toml`: Foundry configuration file.
- `Makefile`: Shortcuts for common development tasks.

### Development
1.  **Planning**: We defined the requirements to demonstrate two core CCIP use cases:
    - A contract for simple cross-chain token transfers.
    - A set of contracts for transferring tokens and executing a function call on the destination chain.

2.  **Contract Implementation**:
    - We developed `CCIPTokenSender.sol` for the simple token transfer use case.
    - We developed `Sender.sol`, `Receiver.sol`, and `Vault.sol` to showcase the "transfer and call" pattern, where `Sender` initiates a transaction to be processed by `Receiver`, which in turn interacts with the `Vault`.

3.  **Testing**:
    - We wrote integration tests using Foundry's `CCIPLocalSimulator` to validate the end-to-end cross-chain messaging logic in a local environment.

4.  **Deployment**:
    - We created scripts in `script/` to automate the deployment of each contract, using a `HelperConfig.s.sol` to manage network-specific addresses and parameters.

5.  **Documentation**:
    - We prepared this README to guide developers.
    - We added explanatory comments in the code.

This project is an excellent starting point for understanding and using Chainlink CCIP in a practical scenario with Foundry.

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/DeploySender.s.sol:DeploySender --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

## Makefile Commands

This project uses a `Makefile` to simplify common tasks.

### Main Commands

-   **Set up the environment (install dependencies and compile):**
    ```shell
    make all
    ```
-   **Compile the contracts:**
    ```shell
    make build
    ```
-   **Run the tests:**
    ```shell
    make test
    ```
-   **Format the code:**
    ```shell
    make format
    ```
-   **Start a local node (Anvil):**
    ```shell
    make anvil
    ```

### Deployment Commands

To run the commands below, you can specify the network. The default is the local Anvil network. To use a testnet like Sepolia, add `ARGS="--network sepolia"` to the end of the command.

-   **Deploy the `CCIPTokenSender` contract:**
    ```shell
    make deploy
    ```
-   **Deploy the `Sender` contract:**
    ```shell
    make deploySender
    ```
-   **Deploy the `Receiver` contract:**
    ```shell
    make deployReceiver
    ```
-   **Deploy the `Vault` contract:**
    ```shell
    make deployVault
    ```
-   **Example of usage with the Sepolia network:**
    ```shell
    make deploySender ARGS="--network sepolia"
    ```

---

# Chainlink CCIP Fundamentals com Foundry

## Guia de Início Rápido

Siga os passos abaixo para inicializar este projeto após clonar o repositório:

1.  Clone o repositório:
    ```bash
    git clone https://github.com/seu-usuario/chainlink-ccip-foundry.git
    cd chainlink-ccip-foundry
    ```

2.  Instale as dependências:
    ```bash
    make install
    ```

3.  Compile os contratos:
    ```bash
    make build
    ```

4.  Execute os testes:
    ```bash
    make test
    ```

5.  (Opcional) Configure variáveis de ambiente em um arquivo `.env` para integração com redes blockchain (ex: `SEPOLIA_RPC_URL`, `ACCOUNT`, `ETHERSCAN_API_KEY`).

## Resumo

Este projeto fornece exemplos práticos de como implementar o **Protocolo de Interoperabilidade Cross-Chain (CCIP) da Chainlink** utilizando o framework Foundry. Ele explora dois padrões fundamentais: **Transferências de Tokens Cross-Chain** e **Transferências de Tokens com Chamadas de Função (Mensagens Arbitrárias)**, demonstrando como construir aplicações que podem se comunicar e transferir valor de forma segura entre diferentes blockchains.

## Descrição

### Motivação
O propósito deste projeto é oferecer exemplos claros e funcionais para desenvolvedores que estão começando com o Chainlink CCIP. Ele cobre os padrões essenciais para criar aplicações "habilitadas para CCIP", permitindo interações seguras e confiáveis através de múltiplas redes blockchain.

### Ferramentas e Tecnologias
- **Foundry**: Framework para desenvolvimento, teste e implantação de contratos inteligentes.
- **Solidity**: Linguagem de programação para contratos inteligentes.
- **Chainlink CCIP**: Para comunicação cross-chain segura, transferência de tokens e mensagens arbitrárias.
- **OpenZeppelin Contracts**: Para implementações seguras e padronizadas de contratos.

### Estrutura do Projeto
O projeto está organizado da seguinte forma:
- `src/`: Contém os contratos inteligentes:
    - `CCIPTokenSender.sol`: Um contrato básico que demonstra como enviar tokens ERC20 para um recebedor em outra blockchain.
    - `Sender.sol`: Um contrato avançado que envia tokens e uma mensagem arbitrária (uma chamada de função) para ser executada em um contrato de destino na blockchain de destino.
    - `Receiver.sol`: A contraparte do `Sender.sol`. Ele recebe os tokens e a mensagem, e então executa a chamada de função especificada no contrato de destino.
    - `Vault.sol`: Um exemplo de contrato de destino na blockchain de destino. O `Receiver` chama sua função `deposit`.
    - `chainlink-local/`: Contratos para testes locais usando o `CCIPLocalSimulator`.
- `script/`: Scripts para a implantação dos contratos.
- `test/`: Contém os scripts de teste para validar a funcionalidade dos contratos.
- `foundry.toml`: Arquivo de configuração do Foundry.
- `Makefile`: Atalhos para tarefas comuns de desenvolvimento.

### Desenvolvimento
1.  **Planejamento**: Definimos os requisitos para demonstrar dois casos de uso centrais do CCIP:
    - Um contrato para transferências simples de tokens entre redes.
    - Um conjunto de contratos para transferir tokens e executar uma chamada de função na rede de destino.

2.  **Implementação dos Contratos**:
    - Desenvolvemos o `CCIPTokenSender.sol` para o caso de uso de transferência simples de tokens.
    - Desenvolvemos `Sender.sol`, `Receiver.sol` e `Vault.sol` para demonstrar o padrão "transfer and call", onde o `Sender` inicia uma transação a ser processada pelo `Receiver`, que por sua vez interage com o `Vault`.

3.  **Testes**:
    - Escrevemos testes de integração usando o `CCIPLocalSimulator` do Foundry para validar a lógica de mensagens cross-chain de ponta a ponta em um ambiente local.

4.  **Implantação**:
    - Criamos scripts em `script/` para automatizar o deploy de cada contrato, utilizando um `HelperConfig.s.sol` para gerenciar endereços e parâmetros específicos de cada rede.

5.  **Documentação**:
    - Elaboramos este README para orientar desenvolvedores.
    - Adicionamos comentários explicativos no código.

Este projeto é um excelente ponto de partida para entender e utilizar o Chainlink CCIP em um cenário prático com o Foundry.

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consiste em:

-   **Forge**: Framework de testes para Ethereum (como Truffle, Hardhat e DappTools).
-   **Cast**: Canivete suíço para interagir com contratos inteligentes EVM, enviar transações e obter dados da cadeia.
-   **Anvil**: Nó Ethereum local, semelhante ao Ganache, Hardhat Network.
-   **Chisel**: REPL solidity rápido, utilitário e verboso.

## Documentação

https://book.getfoundry.sh/

## Uso

### Compilar

```shell
$ forge build
```

### Testar

```shell
$ forge test
```

### Formatar

```shell
$ forge fmt
```

### Capturas de Gas

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Implantar

```shell
$ forge script script/DeploySender.s.sol:DeploySender --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Ajuda

```shell
$ forge --help
$ anvil --help
$ cast --help
```

## Comandos do Makefile

Este projeto usa um `Makefile` para simplificar tarefas comuns.

### Comandos Principais

-   **Configurar o ambiente (instalar dependências e compilar):**
    ```shell
    make all
    ```
-   **Compilar os contratos:**
    ```shell
    make build
    ```
-   **Executar os testes:**
    ```shell
    make test
    ```
-   **Formatar o código:**
    ```shell
    make format
    ```
-   **Iniciar um nó local (Anvil):**
    ```shell
    make anvil
    ```

### Comandos de Implantação

Para executar os comandos abaixo, você pode especificar a rede. O padrão é a rede local Anvil. Para usar uma testnet como Sepolia, adicione `ARGS="--network sepolia"` ao final do comando.

-   **Implantar o contrato `CCIPTokenSender`:**
    ```shell
    make deploy
    ```
-   **Implantar o contrato `Sender`:**
    ```shell
    make deploySender
    ```
-   **Implantar o contrato `Receiver`:**
    ```shell
    make deployReceiver
    ```
-   **Implantar o contrato `Vault`:**
    ```shell
    make deployVault
    ```
-   **Exemplo de uso com a rede Sepolia:**
    ```shell
    make deploySender ARGS="--network sepolia"
    ```
