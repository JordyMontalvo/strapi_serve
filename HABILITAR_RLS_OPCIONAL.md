# 🔒 Habilitar RLS en Supabase (Opcional)

## ⚠️ Nota Importante

**RLS NO es necesario para Strapi**. Strapi funciona perfectamente sin RLS porque maneja su propia autenticación. Solo habilita RLS si quieres una capa adicional de seguridad.

## Si decides habilitar RLS

### Opción 1: Habilitar RLS para todas las tablas de Strapi

Puedes ejecutar este script SQL en el SQL Editor de Supabase:

```sql
-- Habilitar RLS en todas las tablas de Strapi
ALTER TABLE public.strapi_migrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strapi_migrations_internal ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strapi_database_schema ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strapi_core_store_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strapi_webhooks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strapi_ai_localization_jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.files ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.upload_folders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.i18n_locale ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strapi_releases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strapi_release_actions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strapi_workflows ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strapi_workflows_stages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.up_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.up_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.up_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strapi_api_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strapi_api_token_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strapi_transfer_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strapi_transfer_token_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strapi_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strapi_audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strapi_history_versions ENABLE ROW LEVEL SECURITY;

-- Habilitar RLS en tablas de relaciones
ALTER TABLE public.files_related_mph ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.files_folder_lnk ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.upload_folders_parent_lnk ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strapi_release_actions_release_lnk ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strapi_workflows_stage_required_to_publish_lnk ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strapi_workflows_stages_workflow_lnk ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strapi_workflows_stages_permissions_lnk ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.up_permissions_role_lnk ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.up_users_role_lnk ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_permissions_role_lnk ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_users_roles_lnk ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strapi_api_token_permissions_token_lnk ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strapi_transfer_token_permissions_token_lnk ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strapi_audit_logs_user_lnk ENABLE ROW LEVEL SECURITY;
```

### Opción 2: Crear políticas RLS que permitan todo (para Strapi)

Después de habilitar RLS, necesitas crear políticas que permitan a Strapi acceder:

```sql
-- Política que permite todo al usuario de Strapi
-- Esto es necesario porque Strapi accede directamente, no a través de PostgREST

-- Ejemplo para una tabla (repetir para todas las tablas)
CREATE POLICY "Allow Strapi full access" ON public.contents
FOR ALL
TO postgres
USING (true)
WITH CHECK (true);
```

**⚠️ ADVERTENCIA:** Habilitar RLS puede causar problemas si no configuras las políticas correctamente. Strapi podría perder acceso a sus propias tablas.

## Recomendación

**NO habilites RLS** a menos que:
1. Sepas exactamente qué estás haciendo
2. Entiendas cómo funcionan las políticas de RLS
3. Estés dispuesto a depurar problemas de acceso

Para la mayoría de casos con Strapi, **es mejor ignorar estas advertencias**.

## Alternativa: Deshabilitar el linter de Supabase

Si las advertencias te molestan, puedes deshabilitar el linter en la configuración de Supabase, pero esto no es necesario.

