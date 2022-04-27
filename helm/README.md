# Helm Chart for CiviForm

This helm chart deploys a civiform image from Docker Hub.  Your particular deployment settings are declared in the values file you use.

```bash
helm -n dev install civiform . -f ./test-values.yml --set image.tag=latest
```
