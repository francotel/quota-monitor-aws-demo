# Variables
STACK_NAME := cf-stack-quota
TEMPLATE_FILE := cf-template.yml
SPOKE_FILE := cf-target.yml
PROFILE := scc-aws
REGION := us-west-2
BUCKET_NAME := scc-infra-public-us-east-1
S3_TEMPLATE_PATH := cloudformation/$(TEMPLATE_FILE)
S3_SPOKE_PATH := cloudformation/$(SPOKE_FILE)

# URLs de las plantillas en S3
S3_TEMPLATE_URL := https://$(BUCKET_NAME).s3.amazonaws.com/$(S3_TEMPLATE_PATH)
S3_SPOKE_URL := https://$(BUCKET_NAME).s3.amazonaws.com/$(S3_SPOKE_PATH)

# Objetivo por defecto
.PHONY: all
all: validate deploy

# Subir las plantillas a S3
.PHONY: upload
upload: upload-template upload-spoke

.PHONY: upload-template
upload-template:
	@echo "Subiendo la plantilla principal a S3..."
	aws s3 cp $(TEMPLATE_FILE) s3://$(BUCKET_NAME)/$(S3_TEMPLATE_PATH) --profile $(PROFILE)
	@echo "Subida de la plantilla principal completada."

.PHONY: upload-spoke
upload-spoke:
	@echo "Subiendo la plantilla secundaria a S3..."
	aws s3 cp $(SPOKE_FILE) s3://$(BUCKET_NAME)/$(S3_SPOKE_PATH) --profile $(PROFILE)
	@echo "Subida de la plantilla secundaria completada."

# Validar las plantillas de CloudFormation
.PHONY: validate
validate: validate-template validate-spoke

.PHONY: validate-template
validate-template: upload-template
	@echo "Validando la plantilla principal de CloudFormation..."
	aws cloudformation validate-template \
		--template-url $(S3_TEMPLATE_URL) \
		--profile $(PROFILE) \
		--region $(REGION)
	@echo "Validación de la plantilla principal completada."

.PHONY: validate-spoke
validate-spoke: upload-spoke
	@echo "Validando la plantilla secundaria de CloudFormation..."
	aws cloudformation validate-template \
		--template-url $(S3_SPOKE_URL) \
		--profile $(PROFILE) \
		--region $(REGION)
	@echo "Validación de la plantilla secundaria completada."

# Desplegar las plantillas de CloudFormation
.PHONY: deploy
deploy: deploy-template deploy-spoke

.PHONY: deploy-template
deploy-template: upload-template
	@echo "Desplegando la pila principal de CloudFormation..."
	aws cloudformation create-stack \
		--stack-name $(STACK_NAME) \
		--template-url $(S3_TEMPLATE_URL) \
		--profile $(PROFILE) \
		--region $(REGION)
	@echo "Despliegue de la pila principal iniciado. Puedes monitorear el progreso en la consola de AWS."

.PHONY: deploy-spoke
deploy-spoke: upload-spoke
	@echo "Desplegando la pila secundaria de CloudFormation..."
	aws cloudformation create-stack \
		--stack-name $(STACK_NAME)-spoke \
		--template-url $(S3_SPOKE_URL) \
		--profile $(PROFILE) \
		--region $(REGION)
	@echo "Despliegue de la pila secundaria iniciado. Puedes monitorear el progreso en la consola de AWS."

# Actualizar las pilas de CloudFormation (redesplegar cambios)
.PHONY: update
update: update-template update-spoke

.PHONY: update-template
update-template: upload-template
	@echo "Actualizando la pila principal de CloudFormation..."
	aws cloudformation update-stack \
		--stack-name $(STACK_NAME) \
		--template-url $(S3_TEMPLATE_URL) \
		--profile $(PROFILE) \
		--region $(REGION) \
		--capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM
	@echo "Actualización de la pila principal iniciada. Puedes monitorear el progreso en la consola de AWS."

.PHONY: update-spoke
update-spoke: upload-spoke
	@echo "Actualizando la pila secundaria de CloudFormation..."
	aws cloudformation update-stack \
		--stack-name $(STACK_NAME)-spoke \
		--template-url $(S3_SPOKE_URL) \
		--profile $(PROFILE) \
		--region $(REGION) \
		--capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM
	@echo "Actualización de la pila secundaria iniciada. Puedes monitorear el progreso en la consola de AWS."

# Eliminar las pilas de CloudFormation
.PHONY: delete
delete: delete-template delete-spoke

.PHONY: delete-template
delete-template:
	@echo "Eliminando la pila principal de CloudFormation..."
	aws cloudformation delete-stack \
		--stack-name $(STACK_NAME) \
		--profile $(PROFILE) \
		--region $(REGION)
	@echo "Eliminación de la pila principal iniciada. Puedes monitorear el progreso en la consola de AWS."

.PHONY: delete-spoke
delete-spoke:
	@echo "Eliminando la pila secundaria de CloudFormation..."
	aws cloudformation delete-stack \
		--stack-name $(STACK_NAME)-spoke \
		--profile $(PROFILE) \
		--region $(REGION)
	@echo "Eliminación de la pila secundaria iniciada. Puedes monitorear el progreso en la consola de AWS."

# Describir las pilas de CloudFormation
.PHONY: describe
describe: describe-template describe-spoke

.PHONY: describe-template
describe-template:
	@echo "Describiendo la pila principal de CloudFormation..."
	aws cloudformation describe-stacks \
		--stack-name $(STACK_NAME) \
		--profile $(PROFILE) \
		--region $(REGION)

.PHONY: describe-spoke
describe-spoke:
	@echo "Describiendo la pila secundaria de CloudFormation..."
	aws cloudformation describe-stacks \
		--stack-name $(STACK_NAME)-spoke \
		--profile $(PROFILE) \
		--region $(REGION)
