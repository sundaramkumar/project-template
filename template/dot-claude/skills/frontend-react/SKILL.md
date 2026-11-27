---
name: frontend-react
description: Conventions for the React 19 + Vite + Tailwind frontend in frontend (features, API layer, forms, lists, nav and permissions). Use when creating or changing UI code.
---
# Frontend (frontend/src)
- Structure: features/<name>/{api,screens,components,hooks}; cross-feature code in shared/ (components/ui, api, lib, hooks, config).
- API calls only in features/<name>/api/<name>.api.ts via apiFetch from '@/shared/api/client'; types from '@shared'. Never fetch inside components.
- Server state: TanStack Query (invalidate on mutation). Session: Zustand (features/auth/store). No other state libraries.
- Forms: react-hook-form + zodResolver(<shared schema>), the same schema the backend uses.
- Lists: DataTable (shared/components/ui) in serverSide mode on the paginated API: copy UserMaster.tsx.
  Record pages with mode create|edit|view: copy UserFormPage.tsx. Parse route ids with parseRouteId.
- UI: reuse shared/components/ui (Button, Input, Select, Modal, ConfirmDialog, Badge, Drawer...). Tailwind classes only.
  No new UI library or CSS-in-JS. Icons lucide-react, toasts sonner.
- Access: nav item in shared/config/nav.config.ts (module key, implemented: true); route in App.tsx via guard('<module>', ...);
  hide actions the user cannot perform with usePermissions().
- Every data view handles loading, error and empty states.
- Brand name and logos only via shared/config/brand.config.ts. Aliases: '@/' = src, '@shared' = shared/src.
