# Estágio 1: Build da aplicação
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copia apenas o csproj primeiro para restaurar dependências
COPY MottuBracelet/MottuBracelet.csproj MottuBracelet/
WORKDIR /src/MottuBracelet
RUN dotnet restore

# Copia o resto dos arquivos da aplicação
COPY MottuBracelet/. .

# Publica o resultado no diretório /app/publish
RUN dotnet publish -c Release -o /app/publish --no-restore

# Estágio 2: Execução da aplicação
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# Instala o curl (útil para health checks e testes dentro do container)
RUN apt-get update \
 && apt-get install -y --no-install-recommends curl \
 && rm -rf /var/lib/apt/lists/*

# Copia apenas os arquivos publicados do build
COPY --from=build /app/publish .

# Configura a porta da API
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

# Executar com usuário não privilegiado
RUN addgroup --system appuser && adduser --system --ingroup appuser appuser
RUN chown -R appuser:appuser /app
USER appuser

# Arquivo principal da aplicação
ENTRYPOINT ["dotnet", "MottuBracelet.dll"]
