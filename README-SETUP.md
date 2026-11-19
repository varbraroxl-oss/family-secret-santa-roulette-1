# Family Secret Santa Roulette

## Important
Participants enter only their codename. This is convenient but is not identity verification: anyone who knows another participant's codename could draw as them. Use unique private codenames, or add PIN protection before sharing publicly.

## Setup
1. Create a Supabase project.
2. In Supabase SQL Editor, run the complete contents of `supabase-setup.sql`.
3. In Supabase Project Settings > API, copy the Project URL and `service_role` key. Keep the service-role key secret.
4. Deploy this repository to Netlify from GitHub.
5. In Netlify Site configuration > Environment variables, add:
   - `SUPABASE_URL`
   - `SUPABASE_SERVICE_ROLE_KEY`
   - `ADMIN_USERNAME`
   - `ADMIN_PASSWORD`
   - `SESSION_SECRET` (a long random secret)
6. Trigger a new deploy after setting environment variables.
7. Open the site, log in as organizer, paste one codename per line, then Save participants & create draw.

Netlify build settings: publish directory `public`; functions directory `netlify/functions`. `npm run build` is the build command.

Saving the participant list creates a fresh random assignment and resets all draw statuses. Do not save again after participants begin drawing unless you intend to restart the draw.
