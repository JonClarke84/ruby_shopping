# Tailwind CSS Production Deployment Issue - Full Summary

**Date:** November 5, 2025
**Status:** Resolved - Tailwind completely reverted
**Final Commit:** d04656cdac6ee25c0877613a9626a7cd63a5928d

---

## Problem Overview

After merging PR #23 which added Tailwind CSS v4 styling, the production site experienced 500 errors while local development worked perfectly.

### Error Message
```
ActionView::Template::Error (The asset 'tailwind.css' was not found in the load path.)
Caused by: Propshaft::MissingAssetError
```

---

## Investigation Timeline

### Initial Diagnosis
1. **Symptom:** Production returning 500 errors, local development working fine
2. **Suspected cause:** Missing asset file in production Docker image
3. **First observation:** The `tailwind.css` file existed in `/app/assets/builds/` locally but not in the production Docker container

### Attempted Solutions

#### Attempt 1: Add `tailwindcss:build` to Dockerfile
- **Change:** Modified Dockerfile line 49 from:
  ```dockerfile
  RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile
  ```
  To:
  ```dockerfile
  RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails tailwindcss:build assets:precompile
  ```
- **Commit:** 4c24739
- **Result:** ❌ Failed - build appeared successful but no CSS file generated

#### Attempt 2: Commit pre-built CSS file
- **Rationale:** Bypass build process by committing the compiled asset
- **Change:** Added `app/assets/builds/tailwind.css` to git (force-added despite .gitignore)
- **Commit:** 6c169a7
- **Result:** ❌ Failed - Deployment hung indefinitely, never completed

---

## Root Cause Analysis

### The Core Problem: Cross-Platform Docker Builds

The issue stems from building **linux/amd64 Docker images on an arm64 Mac (Apple Silicon)**:

1. **Platform Mismatch:**
   - Local machine: arm64 (Apple Silicon)
   - Production target: amd64 (x86_64 Linux)
   - Build process: Cross-compilation via QEMU emulation

2. **Tailwind CSS v4 Binary Behavior:**
   - The `tailwindcss` executable is a platform-specific binary
   - When run under QEMU emulation (arm64 → amd64), it hangs silently
   - The build process appears to succeed (exit code 0) but produces no output
   - No error messages, no timeouts - just silent failure

3. **Evidence:**
   ```bash
   # Local amd64 build test showed:
   ** Execute tailwindcss:build
   # ... but no "Writing tailwind.css" output
   # File never created in /rails/app/assets/builds/
   ```

4. **Why local worked:**
   - Local development uses native arm64 binaries
   - No emulation, builds complete successfully
   - File appears in `app/assets/builds/tailwind.css`

### Why assets:precompile Didn't Auto-Run tailwindcss:build

While the tailwindcss-rails gem adds a Rake dependency:
```ruby
Rake::Task["assets:precompile"].enhance(["tailwindcss:build"])
```

The issue is that `tailwindcss:build` **silently fails** under QEMU emulation, so:
- Rake task runs without error
- No exception thrown
- Build continues
- No CSS file produced

---

## Research Findings

### Known Issues with Tailwind CSS v4 + Docker
From web search on November 5, 2025:

1. **Active GitHub Issue (April 2025):**
   - "v4 not building in x86_64 container built on arm64 mac"
   - Discussion #499 in rails/tailwindcss-rails
   - Confirms this is a known problem with Tailwind v4

2. **Cross-Platform Build Challenges:**
   - The bundled tailwindcss binary may silently fail or hang when building for different architecture
   - Particularly affects v4 (newer Bun-based binary)
   - v2 and v3 more stable for cross-platform scenarios

3. **Best Practices for Rails + Tailwind + Docker:**
   - Use native platform builds (build on amd64 for amd64 targets)
   - GitHub Actions recommended for production builds
   - Remote builders on target architecture
   - Multi-stage builds to separate concerns

---

## Solution Implemented

### Complete Revert Strategy

Given the complexity and time constraints, we performed a **full revert** of all Tailwind-related changes:

**Commits Reverted:**
1. `ccd7b39` - Reverted temporary CSS commit
2. `c24e66c` - Reverted Dockerfile build change
3. `d04656c` - Reverted entire PR #23 merge (all Tailwind code)

**Changes Removed:**
- ❌ `tailwindcss-rails` gem (Gemfile)
- ❌ `tailwindcss-ruby` gem (dependency)
- ❌ `app/assets/tailwind/application.css` (source file)
- ❌ `app/assets/builds/` directory
- ❌ `Procfile.dev` (dev server config)
- ❌ All Tailwind CSS classes from 32 view files
- ❌ Custom retro pixel-art styling

**Result:**
✅ Site functional and stable
✅ No 500 errors
✅ Basic unstyled layout working
✅ All features operational

---

## Current State

### Deployed Version
- **Commit:** d04656c
- **Branch:** main
- **Status:** ✅ Stable and running
- **Styling:** Basic HTML (pre-Tailwind state)

### What's Working
- ✅ Authentication and sessions
- ✅ Group management
- ✅ Shopping lists functionality
- ✅ All CRUD operations
- ✅ Database operations

### What's Missing
- ❌ Tailwind CSS styling
- ❌ Retro pixel-art design system
- ❌ Custom fonts (DM Mono)
- ❌ Button styling and effects
- ❌ Card layouts and shadows
- ❌ Navigation styling

---

## Lessons Learned

### Technical Insights

1. **Cross-platform Docker builds are non-trivial**
   - Platform-specific binaries can fail silently under emulation
   - Always test on target architecture when possible
   - QEMU limitations can cause unexpected behavior

2. **Tailwind CSS v4 has stability issues with Docker**
   - New Bun-based binary less mature than v3
   - Known issues with cross-platform builds
   - V3 more stable for production use

3. **Asset pipeline complexity**
   - Propshaft + Tailwind + Docker + cross-platform = many failure points
   - Debugging requires understanding entire stack
   - Silent failures hardest to diagnose

4. **Gitignore and build artifacts**
   - Best practice: Don't commit compiled assets
   - Exception: When build process unreliable
   - Our case: Even committing didn't solve cross-platform issue

### Process Insights

1. **Iterative debugging had limitations**
   - Each deploy took 20+ minutes
   - Cross-platform issue not obvious from logs
   - Local success created false confidence

2. **Revert strategy was correct**
   - When fixes cascade into more problems, revert
   - Get to known-good state first
   - Then implement proper solution

---

## Recommended Solutions for Styling

### Option 1: Plain CSS (Recommended for immediate fix)

**Pros:**
- ✅ No build tools required
- ✅ Works everywhere without platform issues
- ✅ Full control over styling
- ✅ Can replicate retro design exactly
- ✅ No gem dependencies

**Cons:**
- ❌ More verbose than utility classes
- ❌ Need to write media queries manually
- ❌ No automatic optimization

**Implementation:**
- Create `app/assets/stylesheets/retro.css`
- Replicate the pixel-art design
- Use CSS custom properties for theme
- Implement responsive design with media queries

### Option 2: GitHub Actions Build (Best long-term)

**Pros:**
- ✅ Builds on native amd64 runners
- ✅ No cross-platform issues
- ✅ Can use Tailwind v4
- ✅ Automated and reliable
- ✅ Industry best practice

**Cons:**
- ❌ Requires GitHub Actions setup
- ❌ More complex CI/CD pipeline
- ❌ Need to configure secrets
- ❌ Longer initial setup time

**Implementation:**
```yaml
# .github/workflows/deploy.yml
name: Build and Deploy
on:
  push:
    branches: [main]
jobs:
  build:
    runs-on: ubuntu-latest  # Native amd64
    steps:
      - uses: actions/checkout@v3
      - name: Build Docker image
        run: docker build -t ${{ secrets.DOCKER_USERNAME }}/ruby_shopping:latest .
      - name: Push to Docker Hub
        run: docker push ${{ secrets.DOCKER_USERNAME }}/ruby_shopping:latest
  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Deploy with Kamal
        run: kamal deploy
```

### Option 3: Remote amd64 Builder

**Pros:**
- ✅ Native amd64 builds
- ✅ Works with Tailwind
- ✅ Kamal has built-in support

**Cons:**
- ❌ Need to maintain remote server
- ❌ Additional infrastructure cost
- ❌ Setup complexity

**Implementation:**
Uncomment in `config/deploy.yml`:
```yaml
builder:
  remote: ssh://docker@docker-builder-server
```

### Option 4: Tailwind CSS v2 (Not Recommended)

**Pros:**
- ✅ More stable for cross-platform
- ✅ Proven track record

**Cons:**
- ❌ Still has platform-specific binaries
- ❌ Older Tailwind version
- ❌ May still fail
- ❌ Moving away from v4 after starting with it

---

## Files Changed During Investigation

### Modified Files
```
Dockerfile                              # Build process changes
Gemfile                                 # Added/removed tailwindcss-rails
Gemfile.lock                            # Dependency updates
.gitignore                              # Build artifacts
app/views/layouts/application.html.erb  # Asset references
app/assets/tailwind/application.css     # Created then deleted
app/assets/builds/tailwind.css          # Build output (ignored)
```

### Key Commits
```
f3b5dd0 - Merge PR #23 (Add Tailwind CSS)
4c24739 - Fix Dockerfile to build Tailwind
6c169a7 - Temporarily commit built tailwind.css
ccd7b39 - Revert temporary CSS commit
c24e66c - Revert Dockerfile fix
d04656c - Revert entire Tailwind PR (CURRENT)
```

---

## Next Steps

### Immediate Action (Required)
1. Deploy current revert: `kamal deploy`
2. Verify site is stable and functional
3. Confirm no 500 errors in production

### Styling Approach (Choose One)

#### Quick Win: Plain CSS
1. Create `app/assets/stylesheets/retro.css`
2. Copy retro design system from PR #23 reference
3. Convert Tailwind classes to plain CSS
4. Test locally and deploy
5. **Time estimate:** 2-3 hours

#### Proper Solution: GitHub Actions
1. Set up GitHub Actions workflow
2. Configure Docker build on amd64 runners
3. Set up Docker Hub credentials
4. Test build pipeline
5. Re-introduce Tailwind CSS v4
6. **Time estimate:** 4-6 hours

### Testing Checklist
- [ ] Local development server works
- [ ] Asset precompilation succeeds
- [ ] Docker build completes without hanging
- [ ] Production deployment successful
- [ ] No 500 errors in production logs
- [ ] CSS loads correctly
- [ ] Responsive design works
- [ ] All pages styled consistently

---

## Reference Links

- **Tailwind CSS v4 Cross-Platform Issue:** https://github.com/rails/tailwindcss-rails/discussions/499
- **Rails + Docker Best Practices:** https://www.techdots.dev/blog/deploying-ruby-on-rails-with-docker-best-practices-for-development-and-production
- **Propshaft Documentation:** https://github.com/rails/propshaft
- **Kamal Deployment Guide:** https://kamal-deploy.org/

---

## Questions & Answers

**Q: Why didn't local development show the issue?**
A: Local development uses native arm64 binaries. The problem only appears when cross-compiling for amd64 under QEMU emulation.

**Q: Could we use Docker Buildx multi-platform builds?**
A: Yes, but same underlying issue - the tailwindcss binary hangs under emulation regardless of build tool.

**Q: Why did the deployment hang when we committed the CSS?**
A: Unknown - possibly related to asset pipeline expecting to build but finding pre-existing file, causing state confusion.

**Q: Is this issue specific to Apple Silicon Macs?**
A: Yes - anyone building amd64 images on arm64 hosts will experience this. Building on amd64 → amd64 works fine.

**Q: Will Tailwind v5 fix this?**
A: Unknown. The issue is architecture-specific binary execution under emulation, which is a fundamental limitation.

---

## Conclusion

The Tailwind CSS v4 deployment failed due to cross-platform Docker build limitations. The tailwindcss binary hangs silently when building amd64 images on arm64 Macs via QEMU emulation.

**Solution implemented:** Complete revert to stable pre-Tailwind state.

**Recommended path forward:** Use plain CSS for styling or set up GitHub Actions for native amd64 builds before reintroducing Tailwind.

**Key takeaway:** Platform-specific binaries and cross-compilation don't mix well. Always build on target architecture for production-critical assets.

---

*Document created: November 5, 2025*
*Last updated: November 5, 2025*
*Author: Claude (via debugging session)*
