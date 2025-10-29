apiVersion: v1
kind: Service
metadata:
  name: ecommerce-service
spec:
  selector:
    app: ecommerce
    version: blue   # or green, whichever is active
  ports:
    - port: 80
      targetPort: 80
      nodePort: 8500    # Choose any free port between 30000–32767 if 8500 is busy
  type: NodePort


