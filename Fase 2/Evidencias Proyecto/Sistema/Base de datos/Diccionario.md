# Diccionario del esquema publicado

Corte: 16-10-2026. Release `8185fd75c143a8d414c179a051e75d1e7b348e32`. Esquema real exportado sin filas, propietarios ni privilegios globales. Las políticas RLS y restricciones sí forman parte del esquema. La tabla técnica de migraciones se distingue del dominio.

## app_user

```sql
id uuid NOT NULL,
    tenant_id uuid,
    email public.citext NOT NULL,
    password_hash text NOT NULL,
    role text NOT NULL,
    full_name text NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    failed_login_count integer DEFAULT 0 NOT NULL,
    locked_until timestamp with time zone,
    CONSTRAINT app_user_role_check CHECK ((role = ANY (ARRAY['field_worker'::text, 'supervisor'::text, 'tenant_admin'::text, 'platform_admin'::text])))
```

## attachment

```sql
id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    owner_type text NOT NULL,
    owner_id uuid NOT NULL,
    file_key text NOT NULL,
    mime text NOT NULL,
    bytes integer NOT NULL,
    width integer,
    height integer,
    captured_at timestamp with time zone NOT NULL,
    client_version integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT attachment_owner_type_check CHECK ((owner_type = ANY (ARRAY['inspection'::text, 'finding'::text, 'log_entry'::text, 'response'::text, 'template_import'::text])))
```

## audit_log

```sql
id uuid NOT NULL,
    actor_id uuid,
    tenant_id uuid,
    action text NOT NULL,
    entity_type text,
    entity_id text,
    payload jsonb,
    occurred_at timestamp with time zone DEFAULT now() NOT NULL
```

## auth_session

```sql
id uuid NOT NULL,
    user_id uuid NOT NULL,
    tenant_id uuid,
    family_id uuid NOT NULL,
    token_hash text NOT NULL,
    issued_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    revoked_at timestamp with time zone
```

## conflict_record

```sql
id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    entity_type text NOT NULL,
    entity_id uuid NOT NULL,
    winner_payload jsonb NOT NULL,
    loser_payload jsonb NOT NULL,
    resolution text DEFAULT 'lww'::text NOT NULL,
    resolved_at timestamp with time zone DEFAULT now() NOT NULL,
    sync_log_id uuid,
    CONSTRAINT conflict_record_entity_type_check CHECK ((entity_type = ANY (ARRAY['inspection'::text, 'response'::text, 'finding'::text, 'log_entry'::text, 'attachment'::text]))),
    CONSTRAINT conflict_record_resolution_check CHECK ((resolution = 'lww'::text))
```

## finding

```sql
id uuid NOT NULL,
    inspection_id uuid,
    response_id uuid,
    tenant_id uuid NOT NULL,
    severity text NOT NULL,
    description text NOT NULL,
    status text DEFAULT 'open'::text NOT NULL,
    captured_at timestamp with time zone NOT NULL,
    client_version integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT finding_severity_check CHECK ((severity = ANY (ARRAY['low'::text, 'medium'::text, 'high'::text, 'critical'::text]))),
    CONSTRAINT finding_status_check CHECK ((status = ANY (ARRAY['open'::text, 'in_progress'::text, 'resolved'::text])))
```

## inspection

```sql
id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    site_id uuid NOT NULL,
    template_id uuid NOT NULL,
    template_version integer NOT NULL,
    executed_by uuid NOT NULL,
    status text NOT NULL,
    captured_at timestamp with time zone NOT NULL,
    synced_at timestamp with time zone,
    client_version integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    location_lat numeric(10,8),
    location_lon numeric(11,8),
    CONSTRAINT inspection_location_bounds_ck CHECK ((((location_lat IS NULL) AND (location_lon IS NULL)) OR (((location_lat >= ('-90'::integer)::numeric) AND (location_lat <= (90)::numeric)) AND ((location_lon >= ('-180'::integer)::numeric) AND (location_lon <= (180)::numeric))))),
    CONSTRAINT inspection_status_check CHECK ((status = ANY (ARRAY['draft'::text, 'in_progress'::text, 'submitted'::text, 'reviewed'::text])))
```

## inspection_response

```sql
id uuid NOT NULL,
    inspection_id uuid NOT NULL,
    template_item_id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    value_ok text,
    value_text text,
    value_number numeric,
    captured_at timestamp with time zone NOT NULL,
    client_version integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    value_json jsonb,
    CONSTRAINT inspection_response_value_ok_check CHECK ((value_ok = ANY (ARRAY['ok'::text, 'nok'::text, 'na'::text])))
```

## log_entry

```sql
id uuid NOT NULL,
    site_id uuid NOT NULL,
    author_id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    entry_text text NOT NULL,
    tags text[] DEFAULT '{}'::text[] NOT NULL,
    shift_date date NOT NULL,
    captured_at timestamp with time zone NOT NULL,
    client_version integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
```

## pgmigrations

```sql
id integer NOT NULL,
    name character varying(255) NOT NULL,
    run_on timestamp without time zone NOT NULL
```

## site

```sql
id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    name text NOT NULL,
    kind text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT site_kind_check CHECK ((kind = ANY (ARRAY['mining'::text, 'construction'::text])))
```

## sync_log

```sql
id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    user_id uuid,
    device_id uuid NOT NULL,
    batch_id uuid NOT NULL,
    records_total integer NOT NULL,
    records_ok integer NOT NULL,
    records_failed integer NOT NULL,
    started_at timestamp with time zone NOT NULL,
    finished_at timestamp with time zone,
    status text NOT NULL,
    CONSTRAINT sync_log_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'ok'::text, 'partial'::text, 'failed'::text])))
```

## template

```sql
id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    name text NOT NULL,
    description text,
    status text DEFAULT 'active'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT template_status_check CHECK ((status = ANY (ARRAY['active'::text, 'archived'::text])))
```

## template_assignment

```sql
id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    template_revision_id uuid NOT NULL,
    site_id uuid,
    role text NOT NULL,
    active boolean DEFAULT true NOT NULL,
    assigned_by uuid NOT NULL,
    assigned_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT template_assignment_role_check CHECK ((role = ANY (ARRAY['field_worker'::text, 'supervisor'::text])))
```

## template_imports

```sql
id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    uploaded_by uuid NOT NULL,
    file_key text NOT NULL,
    file_name text NOT NULL,
    status text NOT NULL,
    proposed_schema jsonb,
    error text,
    confirmed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT template_imports_status_check CHECK ((status = ANY (ARRAY['uploaded'::text, 'parsed'::text, 'proposed'::text, 'confirmed'::text, 'failed'::text])))
```

## template_item

```sql
id uuid NOT NULL,
    section_id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    "position" integer NOT NULL,
    prompt text NOT NULL,
    response_type text NOT NULL,
    require_finding_on_nok boolean DEFAULT false NOT NULL,
    props jsonb,
    help text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT template_item_position_check CHECK (("position" >= 0)),
    CONSTRAINT template_item_response_type_check CHECK ((response_type = ANY (ARRAY['ok_nok_na'::text, 'text'::text, 'numeric'::text, 'date'::text, 'time'::text, 'select_single'::text, 'select_multiple'::text, 'photo'::text])))
```

## template_revision

```sql
id uuid NOT NULL,
    template_id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    version integer,
    definition jsonb NOT NULL,
    status text DEFAULT 'draft'::text NOT NULL,
    source_import_id uuid,
    published_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    published_seq bigint,
    CONSTRAINT template_revision_published_seq_check CHECK (((status <> 'published'::text) OR (published_seq IS NOT NULL))),
    CONSTRAINT template_revision_status_check CHECK ((status = ANY (ARRAY['draft'::text, 'published'::text, 'archived'::text])))
```

## template_section

```sql
id uuid NOT NULL,
    revision_id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    "position" integer NOT NULL,
    title text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT template_section_position_check CHECK (("position" >= 0))
```

## tenant

```sql
id uuid NOT NULL,
    name text NOT NULL,
    slug text NOT NULL,
    status text DEFAULT 'active'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT tenant_status_check CHECK ((status = ANY (ARRAY['active'::text, 'suspended'::text])))
```
