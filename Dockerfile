apiVersion: v1
kind: Service
metadata:
  name: ecommerce-service
spec:
  selector:
    app: ecommerce
    version: blue   # initially points to blue
  ports:
    - port: 80
      targetPort: 80
      nodePort: 8500   # or any free port between 30000–32767
  type: NodePort


