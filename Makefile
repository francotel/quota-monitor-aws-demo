# Variables
STACK_NAME := cf-stack-quota
TEMPLATE_FILE := cf-template.yml
PROFILE := scc-aws
REGION := us-west-2
BUCKET_NAME := scc-infra-public-us-east-1
S3_TEMPLATE_PATH := cloudformation/$(TEMPLATE_FILE)

# URL de la plantilla en S3
S3_TEMPLATE_URL := https://$(BUCKET_NAME).s3.amazonaws.com/$(S3_TEMPLATE_PATH)

# Objetivo por defecto
.PHONY: all
all: validate deploy

# Subir la plantilla a S3
.PHONY: upload
upload:
	@echo "Subiendo la plantilla a S3..."
	aws s3 cp $(TEMPLATE_FILE) s3://$(BUCKET_NAME)/$(S3_TEMPLATE_PATH) --profile $(PROFILE)
	@echo "Subida completada."

# Validar la plantilla de CloudFormation
.PHONY: validate
validate: upload
	@echo "Validando la plantilla de CloudFormation..."
	aws cloudformation validate-template \
		--template-url $(S3_TEMPLATE_URL) \
		--profile $(PROFILE) \
		--region $(REGION)
	@echo "Validación completada."

# Desplegar la plantilla de CloudFormation
.PHONY: deploy
deploy: upload
	@echo "Desplegando la pila de CloudFormation..."
	aws cloudformation create-stack \
		--stack-name $(STACK_NAME) \
		--template-url $(S3_TEMPLATE_URL) \
		--profile $(PROFILE) \
		--region $(REGION)
	@echo "Despliegue iniciado. Puedes monitorear el progreso en la consola de AWS."

# Actualizar la pila de CloudFormation (redesplegar cambios)
.PHONY: update
update: upload
	@echo "Actualizando la pila de CloudFormation..."
	aws cloudformation update-stack \
		--stack-name $(STACK_NAME) \
		--template-url $(S3_TEMPLATE_URL) \
		--profile $(PROFILE) \
		--region $(REGION) \
		--capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM
	@echo "Actualización iniciada. Puedes monitorear el progreso en la consola de AWS."

# Eliminar la pila de CloudFormation
.PHONY: delete
delete:
	@echo "Eliminando la pila de CloudFormation..."
	aws cloudformation delete-stack \
		--stack-name $(STACK_NAME) \
		--profile $(PROFILE) \
		--region $(REGION)
	@echo "Eliminación iniciada. Puedes monitorear el progreso en la consola de AWS."

# Describir la pila de CloudFormation
.PHONY: describe
describe:
	@echo "Describiendo la pila de CloudFormation..."
	aws cloudformation describe-stacks \
		--stack-name $(STACK_NAME) \
		--profile $(PROFILE) \
		--region $(REGION)