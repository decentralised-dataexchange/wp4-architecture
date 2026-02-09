rm -f main.md
echo '# WE BUILD – Architecture & Integration Blueprint (D4.1)' >> main.md
cat 01-executive-summary.md >> main.md

rm -f main-body.md
cat 02-regulatory-alignment.md >> main-body.md
cat 03-architecture-overview.md >> main-body.md
cat 04-integration-model.md >> main-body.md
cat 05-data-and-semantics.md >> main-body.md
cat 06-trust-and-security.md >> main-body.md
cat 07-governance-and-adr.md >> main-body.md
cat 08-test-and-validation.md >> main-body.md
cat 09-roadmap.md >> main-body.md
rm -f main-body-enum.md
markdown-enum main-body.md 1 main-body-enum.md

cat main-body-enum.md >> main.md

echo >> main.md
cat appendix-glossary.md >> main.md

echo >> main.md
cat appendix-history.md >> main.md

echo "Running kramdoc..."
kramdoc --auto-ids main.md -o main.adoc

echo "Generating HTML..."
asciidoctor --attribute toc=left --doctype book main.adoc

echo "Generating PDF..."
asciidoctor-pdf --attribute toc=left --doctype book main.adoc --out-file main.pdf
