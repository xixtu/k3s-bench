# Création du namespace
kubectl create ns kbench

# Déploiement des fichiers
kubectl apply -f fio-slow.yaml
kubectl apply -f fio-fast.yaml
kubectl apply -f fio-ultra.yaml
kubectl apply -f fio-local.yaml

# Attendre que tous les pods soient en Completed
echo "Attente que tous les pods soient terminés..."
while true; do
  incomplete=$(kubectl get pods -n kbench --field-selector=status.phase!=Succeeded -o jsonpath='{.items[*].metadata.name}')
  if [ -z "$incomplete" ]; then
    echo "Tous les pods sont terminés."
    break
  fi
  echo "Pods encore en cours: $incomplete"
  sleep 5
done

cd longhorn-live-reports

# Récupération des logs
for p in $(kubectl get pods -n kbench -o jsonpath='{.items[*].metadata.name}'); do
  kubectl logs -n kbench "$p" > "lo-${p}.txt"
done
 cd..

kubectl delete ns kbench