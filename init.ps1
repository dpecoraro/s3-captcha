Param(
    [Parameter(Mandatory=$true)]
    [string]$action
)

if(-not (Test-Path ./terraform.tfstate.backup)) {
    Write-Host "arquivo de inicialização não encontrado, rodando init"
    terraform init
}

$envFile = "./.env"
$envContent = Get-Content $envFilePath -Raw

$matches = [regex]::Matches($envContent, "(?m)^(.*?)=(.*)")

foreach ($match in $matches) {
    $key = $match.Groups[1].Value.Trim()
    $value = $match.Groups[2].Value.Trim()
    Write-Host "$key = $value"
    [System.Environment]::SetEnvironmentVariable($key, $value, [System.EnvironmentVariableTarget]::Process)
}

$env:TF_VAR_region=$AWS_DEFAULT_REGION
$env:TF_VAR_aws_access_key=$AWS_ACCESS_KEY_ID
$env:TF_VAR_aws_secret_key=$AWS_SECRET_ACCESS_KEY

switch ($action) {
    'apply' {
        Write-Host "Running terraform plan"
        terraform plan
    
        Write-Host "Applying terraform"
        terraform apply -auto-approve
    
        Write-Host "Syncing index.html using aws CLI"
    
        aws s3 cp index.html s3://captcha-ec0ec570-a253-2213-7cd4-194aa13aee93
        aws s3 cp error.html s3://captcha-ec0ec570-a253-2213-7cd4-194aa13aee93
        break
    }
    'destroy' {
        Write-Host "Running terraform destroy"
        terraform destroy -auto-approve
        break
    }
    default {
        Write-Host "Ação desconhecida. Por favor, use 'apply' ou 'destroy'."
        exit 1
    }
}

