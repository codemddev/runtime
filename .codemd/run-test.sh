#!/usr/bin/env bash
root="$(pwd)"
target="${1:-all}"
status=0
mkdir -p "$root/codemd-reports" "$root/.codemd/test-results"
if [ "$target" = "finalize" ]; then
  if [ ! -f "$root/.codemd/test-results/0.exit" ]; then echo "CODEMD_TIMEOUT 0"; echo "CODEMD_RESULT 0 124"; status=1; else code="$(cat "$root/.codemd/test-results/0.exit")"; [ "$code" -eq 0 ] || status=1; fi
  exit "$status"
fi
if [ "$target" = "all" ] || [ "$target" = "0" ]; then
( cd . && eval 'dotnet test src/mono/wasm/Wasm.Build.Tests/Wasm.Build.Tests.csproj --filter '"'"'FullyQualifiedName~PInvokeTableGeneratorTests'"'"'' ); code=$?
echo "$code" > "$root/.codemd/test-results/0.exit"
echo "CODEMD_RESULT 0 $code"; [ "$code" -eq 0 ] || status=1
if [ "$code" -ne 0 ] && [ "$code" -ne 124 ] && [ "$code" -ne 126 ] && [ "$code" -ne 127 ]; then passes=0; for n in 1 2; do ( cd . && timeout 300 bash -c 'dotnet test src/mono/wasm/Wasm.Build.Tests/Wasm.Build.Tests.csproj --filter '"'"'FullyQualifiedName~PInvokeTableGeneratorTests'"'"'' ) >/dev/null 2>&1 && passes=$((passes+1)); done; echo "CODEMD_RERUN 0 $passes 2"; fi
fi
exit "$status"
