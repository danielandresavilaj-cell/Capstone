--
-- PostgreSQL database dump
--


-- Dumped from database version 16.15
-- Dumped by pg_dump version 16.15

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: app_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.app_user (
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
);


--
-- Name: attachment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attachment (
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
);


--
-- Name: audit_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_log (
    id uuid NOT NULL,
    actor_id uuid,
    tenant_id uuid,
    action text NOT NULL,
    entity_type text,
    entity_id text,
    payload jsonb,
    occurred_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: auth_session; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_session (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    tenant_id uuid,
    family_id uuid NOT NULL,
    token_hash text NOT NULL,
    issued_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    revoked_at timestamp with time zone
);


--
-- Name: conflict_record; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.conflict_record (
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
);


--
-- Name: finding; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.finding (
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
);


--
-- Name: inspection; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inspection (
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
);


--
-- Name: inspection_response; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inspection_response (
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
);


--
-- Name: log_entry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.log_entry (
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
);


--
-- Name: pgmigrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pgmigrations (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    run_on timestamp without time zone NOT NULL
);


--
-- Name: pgmigrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pgmigrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pgmigrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pgmigrations_id_seq OWNED BY public.pgmigrations.id;


--
-- Name: site; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site (
    id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    name text NOT NULL,
    kind text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT site_kind_check CHECK ((kind = ANY (ARRAY['mining'::text, 'construction'::text])))
);


--
-- Name: sync_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sync_log (
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
);


--
-- Name: template; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.template (
    id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    name text NOT NULL,
    description text,
    status text DEFAULT 'active'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT template_status_check CHECK ((status = ANY (ARRAY['active'::text, 'archived'::text])))
);


--
-- Name: template_assignment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.template_assignment (
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
);


--
-- Name: template_imports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.template_imports (
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
);


--
-- Name: template_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.template_item (
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
);


--
-- Name: template_revision; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.template_revision (
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
);


--
-- Name: template_revision_published_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.template_revision_published_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: template_section; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.template_section (
    id uuid NOT NULL,
    revision_id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    "position" integer NOT NULL,
    title text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT template_section_position_check CHECK (("position" >= 0))
);


--
-- Name: tenant; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant (
    id uuid NOT NULL,
    name text NOT NULL,
    slug text NOT NULL,
    status text DEFAULT 'active'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT tenant_status_check CHECK ((status = ANY (ARRAY['active'::text, 'suspended'::text])))
);


--
-- Name: pgmigrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pgmigrations ALTER COLUMN id SET DEFAULT nextval('public.pgmigrations_id_seq'::regclass);


--
-- Name: app_user app_user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_pkey PRIMARY KEY (id);


--
-- Name: attachment attachment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attachment
    ADD CONSTRAINT attachment_pkey PRIMARY KEY (id);


--
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (id);


--
-- Name: auth_session auth_session_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_session
    ADD CONSTRAINT auth_session_pkey PRIMARY KEY (id);


--
-- Name: auth_session auth_session_token_hash_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_session
    ADD CONSTRAINT auth_session_token_hash_key UNIQUE (token_hash);


--
-- Name: conflict_record conflict_record_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conflict_record
    ADD CONSTRAINT conflict_record_pkey PRIMARY KEY (id);


--
-- Name: finding finding_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.finding
    ADD CONSTRAINT finding_pkey PRIMARY KEY (id);


--
-- Name: inspection inspection_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inspection
    ADD CONSTRAINT inspection_pkey PRIMARY KEY (id);


--
-- Name: inspection_response inspection_response_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inspection_response
    ADD CONSTRAINT inspection_response_pkey PRIMARY KEY (id);


--
-- Name: log_entry log_entry_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_entry
    ADD CONSTRAINT log_entry_pkey PRIMARY KEY (id);


--
-- Name: pgmigrations pgmigrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pgmigrations
    ADD CONSTRAINT pgmigrations_pkey PRIMARY KEY (id);


--
-- Name: site site_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site
    ADD CONSTRAINT site_pkey PRIMARY KEY (id);


--
-- Name: sync_log sync_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sync_log
    ADD CONSTRAINT sync_log_pkey PRIMARY KEY (id);


--
-- Name: template_assignment template_assignment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_assignment
    ADD CONSTRAINT template_assignment_pkey PRIMARY KEY (id);


--
-- Name: template_imports template_imports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_imports
    ADD CONSTRAINT template_imports_pkey PRIMARY KEY (id);


--
-- Name: template_item template_item_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_item
    ADD CONSTRAINT template_item_pkey PRIMARY KEY (id);


--
-- Name: template template_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template
    ADD CONSTRAINT template_pkey PRIMARY KEY (id);


--
-- Name: template_revision template_revision_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_revision
    ADD CONSTRAINT template_revision_pkey PRIMARY KEY (id);


--
-- Name: template_section template_section_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_section
    ADD CONSTRAINT template_section_pkey PRIMARY KEY (id);


--
-- Name: tenant tenant_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant
    ADD CONSTRAINT tenant_pkey PRIMARY KEY (id);


--
-- Name: tenant tenant_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant
    ADD CONSTRAINT tenant_slug_key UNIQUE (slug);


--
-- Name: app_user_tenant_email_uidx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX app_user_tenant_email_uidx ON public.app_user USING btree (tenant_id, email);


--
-- Name: attachment_owner_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX attachment_owner_idx ON public.attachment USING btree (owner_id);


--
-- Name: attachment_tenant_captured_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX attachment_tenant_captured_idx ON public.attachment USING btree (tenant_id, captured_at DESC);


--
-- Name: audit_log_occurred_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_log_occurred_idx ON public.audit_log USING btree (occurred_at DESC);


--
-- Name: audit_log_tenant_occurred_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_log_tenant_occurred_idx ON public.audit_log USING btree (tenant_id, occurred_at DESC);


--
-- Name: auth_session_family_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_session_family_idx ON public.auth_session USING btree (family_id);


--
-- Name: auth_session_user_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_session_user_idx ON public.auth_session USING btree (user_id);


--
-- Name: conflict_record_entity_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX conflict_record_entity_idx ON public.conflict_record USING btree (tenant_id, entity_type, entity_id);


--
-- Name: conflict_record_tenant_resolved_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX conflict_record_tenant_resolved_idx ON public.conflict_record USING btree (tenant_id, resolved_at DESC);


--
-- Name: finding_tenant_captured_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX finding_tenant_captured_idx ON public.finding USING btree (tenant_id, captured_at DESC);


--
-- Name: finding_tenant_severity_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX finding_tenant_severity_idx ON public.finding USING btree (tenant_id, severity) WHERE (status <> 'resolved'::text);


--
-- Name: inspection_response_inspection_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inspection_response_inspection_idx ON public.inspection_response USING btree (inspection_id);


--
-- Name: inspection_response_item_uidx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inspection_response_item_uidx ON public.inspection_response USING btree (inspection_id, template_item_id);


--
-- Name: inspection_response_tenant_captured_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inspection_response_tenant_captured_idx ON public.inspection_response USING btree (tenant_id, captured_at DESC);


--
-- Name: inspection_tenant_captured_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inspection_tenant_captured_idx ON public.inspection USING btree (tenant_id, captured_at DESC);


--
-- Name: log_entry_tenant_captured_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX log_entry_tenant_captured_idx ON public.log_entry USING btree (tenant_id, captured_at DESC);


--
-- Name: site_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX site_tenant_idx ON public.site USING btree (tenant_id);


--
-- Name: sync_log_tenant_batch_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sync_log_tenant_batch_idx ON public.sync_log USING btree (tenant_id, batch_id);


--
-- Name: sync_log_tenant_started_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sync_log_tenant_started_idx ON public.sync_log USING btree (tenant_id, started_at DESC);


--
-- Name: template_assignment_global_uidx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX template_assignment_global_uidx ON public.template_assignment USING btree (template_revision_id, role) WHERE (site_id IS NULL);


--
-- Name: template_assignment_revision_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX template_assignment_revision_idx ON public.template_assignment USING btree (template_revision_id);


--
-- Name: template_assignment_site_role_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX template_assignment_site_role_idx ON public.template_assignment USING btree (tenant_id, site_id, role);


--
-- Name: template_assignment_site_uidx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX template_assignment_site_uidx ON public.template_assignment USING btree (template_revision_id, site_id, role) WHERE (site_id IS NOT NULL);


--
-- Name: template_assignment_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX template_assignment_tenant_idx ON public.template_assignment USING btree (tenant_id);


--
-- Name: template_imports_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX template_imports_status_idx ON public.template_imports USING btree (tenant_id, status);


--
-- Name: template_imports_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX template_imports_tenant_idx ON public.template_imports USING btree (tenant_id);


--
-- Name: template_item_section_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX template_item_section_idx ON public.template_item USING btree (section_id, "position");


--
-- Name: template_item_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX template_item_tenant_idx ON public.template_item USING btree (tenant_id);


--
-- Name: template_revision_published_seq_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX template_revision_published_seq_idx ON public.template_revision USING btree (published_seq) WHERE (published_seq IS NOT NULL);


--
-- Name: template_revision_template_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX template_revision_template_idx ON public.template_revision USING btree (template_id);


--
-- Name: template_revision_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX template_revision_tenant_idx ON public.template_revision USING btree (tenant_id);


--
-- Name: template_revision_version_uidx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX template_revision_version_uidx ON public.template_revision USING btree (template_id, version) WHERE (version IS NOT NULL);


--
-- Name: template_section_revision_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX template_section_revision_idx ON public.template_section USING btree (revision_id, "position");


--
-- Name: template_section_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX template_section_tenant_idx ON public.template_section USING btree (tenant_id);


--
-- Name: template_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX template_tenant_idx ON public.template USING btree (tenant_id);


--
-- Name: app_user app_user_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenant(id) ON DELETE CASCADE;


--
-- Name: attachment attachment_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attachment
    ADD CONSTRAINT attachment_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenant(id) ON DELETE CASCADE;


--
-- Name: audit_log audit_log_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.app_user(id) ON DELETE SET NULL;


--
-- Name: audit_log audit_log_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenant(id) ON DELETE SET NULL;


--
-- Name: auth_session auth_session_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_session
    ADD CONSTRAINT auth_session_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenant(id) ON DELETE CASCADE;


--
-- Name: auth_session auth_session_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_session
    ADD CONSTRAINT auth_session_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id) ON DELETE CASCADE;


--
-- Name: conflict_record conflict_record_sync_log_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conflict_record
    ADD CONSTRAINT conflict_record_sync_log_id_fkey FOREIGN KEY (sync_log_id) REFERENCES public.sync_log(id);


--
-- Name: conflict_record conflict_record_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conflict_record
    ADD CONSTRAINT conflict_record_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenant(id) ON DELETE CASCADE;


--
-- Name: finding finding_inspection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.finding
    ADD CONSTRAINT finding_inspection_id_fkey FOREIGN KEY (inspection_id) REFERENCES public.inspection(id) ON DELETE SET NULL;


--
-- Name: finding finding_response_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.finding
    ADD CONSTRAINT finding_response_id_fkey FOREIGN KEY (response_id) REFERENCES public.inspection_response(id) ON DELETE SET NULL;


--
-- Name: finding finding_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.finding
    ADD CONSTRAINT finding_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenant(id) ON DELETE CASCADE;


--
-- Name: inspection inspection_executed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inspection
    ADD CONSTRAINT inspection_executed_by_fkey FOREIGN KEY (executed_by) REFERENCES public.app_user(id);


--
-- Name: inspection_response inspection_response_inspection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inspection_response
    ADD CONSTRAINT inspection_response_inspection_id_fkey FOREIGN KEY (inspection_id) REFERENCES public.inspection(id) ON DELETE CASCADE;


--
-- Name: inspection_response inspection_response_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inspection_response
    ADD CONSTRAINT inspection_response_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenant(id) ON DELETE CASCADE;


--
-- Name: inspection inspection_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inspection
    ADD CONSTRAINT inspection_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id) ON DELETE CASCADE;


--
-- Name: inspection inspection_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inspection
    ADD CONSTRAINT inspection_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenant(id) ON DELETE CASCADE;


--
-- Name: log_entry log_entry_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_entry
    ADD CONSTRAINT log_entry_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.app_user(id);


--
-- Name: log_entry log_entry_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_entry
    ADD CONSTRAINT log_entry_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id) ON DELETE CASCADE;


--
-- Name: log_entry log_entry_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_entry
    ADD CONSTRAINT log_entry_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenant(id) ON DELETE CASCADE;


--
-- Name: site site_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site
    ADD CONSTRAINT site_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenant(id) ON DELETE CASCADE;


--
-- Name: sync_log sync_log_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sync_log
    ADD CONSTRAINT sync_log_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenant(id) ON DELETE CASCADE;


--
-- Name: sync_log sync_log_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sync_log
    ADD CONSTRAINT sync_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id);


--
-- Name: template_assignment template_assignment_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_assignment
    ADD CONSTRAINT template_assignment_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id) ON DELETE CASCADE;


--
-- Name: template_assignment template_assignment_template_revision_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_assignment
    ADD CONSTRAINT template_assignment_template_revision_id_fkey FOREIGN KEY (template_revision_id) REFERENCES public.template_revision(id) ON DELETE CASCADE;


--
-- Name: template_assignment template_assignment_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_assignment
    ADD CONSTRAINT template_assignment_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenant(id) ON DELETE CASCADE;


--
-- Name: template_imports template_imports_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_imports
    ADD CONSTRAINT template_imports_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenant(id) ON DELETE CASCADE;


--
-- Name: template_item template_item_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_item
    ADD CONSTRAINT template_item_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.template_section(id) ON DELETE CASCADE;


--
-- Name: template_item template_item_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_item
    ADD CONSTRAINT template_item_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenant(id) ON DELETE CASCADE;


--
-- Name: template_revision template_revision_source_import_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_revision
    ADD CONSTRAINT template_revision_source_import_id_fkey FOREIGN KEY (source_import_id) REFERENCES public.template_imports(id) ON DELETE SET NULL;


--
-- Name: template_revision template_revision_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_revision
    ADD CONSTRAINT template_revision_template_id_fkey FOREIGN KEY (template_id) REFERENCES public.template(id) ON DELETE CASCADE;


--
-- Name: template_revision template_revision_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_revision
    ADD CONSTRAINT template_revision_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenant(id) ON DELETE CASCADE;


--
-- Name: template_section template_section_revision_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_section
    ADD CONSTRAINT template_section_revision_id_fkey FOREIGN KEY (revision_id) REFERENCES public.template_revision(id) ON DELETE CASCADE;


--
-- Name: template_section template_section_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_section
    ADD CONSTRAINT template_section_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenant(id) ON DELETE CASCADE;


--
-- Name: template template_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template
    ADD CONSTRAINT template_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenant(id) ON DELETE CASCADE;


--
-- Name: app_user; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.app_user ENABLE ROW LEVEL SECURITY;

--
-- Name: attachment; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.attachment ENABLE ROW LEVEL SECURITY;

--
-- Name: audit_log; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.audit_log ENABLE ROW LEVEL SECURITY;

--
-- Name: auth_session; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.auth_session ENABLE ROW LEVEL SECURITY;

--
-- Name: template_item catalog_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY catalog_delete ON public.template_item FOR DELETE USING (((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid) AND (EXISTS ( SELECT 1
   FROM (public.template_revision r
     JOIN public.template_section s ON ((s.revision_id = r.id)))
  WHERE ((s.id = template_item.section_id) AND (r.status = 'draft'::text))))));


--
-- Name: template_section catalog_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY catalog_delete ON public.template_section FOR DELETE USING (((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid) AND (EXISTS ( SELECT 1
   FROM public.template_revision r
  WHERE ((r.id = template_section.revision_id) AND (r.status = 'draft'::text))))));


--
-- Name: template_item catalog_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY catalog_insert ON public.template_item FOR INSERT WITH CHECK (((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid) AND (EXISTS ( SELECT 1
   FROM (public.template_revision r
     JOIN public.template_section s ON ((s.revision_id = r.id)))
  WHERE ((s.id = template_item.section_id) AND (r.status = 'draft'::text))))));


--
-- Name: template_section catalog_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY catalog_insert ON public.template_section FOR INSERT WITH CHECK (((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid) AND (EXISTS ( SELECT 1
   FROM public.template_revision r
  WHERE ((r.id = template_section.revision_id) AND (r.status = 'draft'::text))))));


--
-- Name: template_item catalog_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY catalog_select ON public.template_item FOR SELECT USING ((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid));


--
-- Name: template_section catalog_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY catalog_select ON public.template_section FOR SELECT USING ((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid));


--
-- Name: template_item catalog_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY catalog_update ON public.template_item FOR UPDATE USING (((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid) AND (EXISTS ( SELECT 1
   FROM (public.template_revision r
     JOIN public.template_section s ON ((s.revision_id = r.id)))
  WHERE ((s.id = template_item.section_id) AND (r.status = 'draft'::text))))));


--
-- Name: template_section catalog_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY catalog_update ON public.template_section FOR UPDATE USING (((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid) AND (EXISTS ( SELECT 1
   FROM public.template_revision r
  WHERE ((r.id = template_section.revision_id) AND (r.status = 'draft'::text))))));


--
-- Name: conflict_record; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.conflict_record ENABLE ROW LEVEL SECURITY;

--
-- Name: finding; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.finding ENABLE ROW LEVEL SECURITY;

--
-- Name: inspection; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.inspection ENABLE ROW LEVEL SECURITY;

--
-- Name: inspection_response; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.inspection_response ENABLE ROW LEVEL SECURITY;

--
-- Name: log_entry; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.log_entry ENABLE ROW LEVEL SECURITY;

--
-- Name: template_revision revision_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY revision_delete ON public.template_revision FOR DELETE USING (((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid) AND (status = 'draft'::text)));


--
-- Name: template_revision revision_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY revision_insert ON public.template_revision FOR INSERT WITH CHECK (((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid) AND (status = 'draft'::text)));


--
-- Name: template_revision revision_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY revision_select ON public.template_revision FOR SELECT USING ((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid));


--
-- Name: template_revision revision_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY revision_update ON public.template_revision FOR UPDATE USING (((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid) AND (status = 'draft'::text))) WITH CHECK (((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid) AND (status = ANY (ARRAY['draft'::text, 'published'::text, 'archived'::text]))));


--
-- Name: site; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.site ENABLE ROW LEVEL SECURITY;

--
-- Name: sync_log; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.sync_log ENABLE ROW LEVEL SECURITY;

--
-- Name: template; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.template ENABLE ROW LEVEL SECURITY;

--
-- Name: template_assignment; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.template_assignment ENABLE ROW LEVEL SECURITY;

--
-- Name: template_assignment template_assignment_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY template_assignment_delete ON public.template_assignment FOR DELETE USING ((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid));


--
-- Name: template_assignment template_assignment_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY template_assignment_insert ON public.template_assignment FOR INSERT WITH CHECK ((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid));


--
-- Name: template_assignment template_assignment_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY template_assignment_select ON public.template_assignment FOR SELECT USING ((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid));


--
-- Name: template_assignment template_assignment_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY template_assignment_update ON public.template_assignment FOR UPDATE USING ((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid)) WITH CHECK ((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid));


--
-- Name: template_imports; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.template_imports ENABLE ROW LEVEL SECURITY;

--
-- Name: template_imports template_imports_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY template_imports_delete ON public.template_imports FOR DELETE USING ((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid));


--
-- Name: template_imports template_imports_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY template_imports_insert ON public.template_imports FOR INSERT WITH CHECK ((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid));


--
-- Name: template_imports template_imports_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY template_imports_select ON public.template_imports FOR SELECT USING ((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid));


--
-- Name: template_imports template_imports_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY template_imports_update ON public.template_imports FOR UPDATE USING ((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid)) WITH CHECK ((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid));


--
-- Name: template_item; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.template_item ENABLE ROW LEVEL SECURITY;

--
-- Name: template_revision; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.template_revision ENABLE ROW LEVEL SECURITY;

--
-- Name: template_section; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.template_section ENABLE ROW LEVEL SECURITY;

--
-- Name: tenant; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tenant ENABLE ROW LEVEL SECURITY;

--
-- Name: app_user tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.app_user USING ((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid)) WITH CHECK ((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid));


--
-- Name: attachment tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.attachment USING ((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid)) WITH CHECK ((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid));


--
-- Name: audit_log tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.audit_log USING (((tenant_id IS NULL) OR (tenant_id = (current_setting('app.tenant_id'::text, true))::uuid))) WITH CHECK (((tenant_id IS NULL) OR (tenant_id = (current_setting('app.tenant_id'::text, true))::uuid)));


--
-- Name: auth_session tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.auth_session USING (((tenant_id IS NULL) OR (tenant_id = (current_setting('app.tenant_id'::text, true))::uuid))) WITH CHECK (((tenant_id IS NULL) OR (tenant_id = (current_setting('app.tenant_id'::text, true))::uuid)));


--
-- Name: conflict_record tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.conflict_record USING ((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid)) WITH CHECK ((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid));


--
-- Name: finding tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.finding USING ((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid)) WITH CHECK ((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid));


--
-- Name: inspection tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.inspection USING ((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid)) WITH CHECK ((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid));


--
-- Name: inspection_response tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.inspection_response USING ((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid)) WITH CHECK ((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid));


--
-- Name: log_entry tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.log_entry USING ((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid)) WITH CHECK ((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid));


--
-- Name: site tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.site USING ((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid)) WITH CHECK ((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid));


--
-- Name: sync_log tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.sync_log USING ((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid)) WITH CHECK ((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid));


--
-- Name: template tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.template USING ((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid)) WITH CHECK ((tenant_id = (current_setting('app.tenant_id'::text, true))::uuid));


--
-- Name: tenant tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.tenant USING ((id = (current_setting('app.tenant_id'::text, true))::uuid)) WITH CHECK ((id = (current_setting('app.tenant_id'::text, true))::uuid));


--
-- PostgreSQL database dump complete
--
