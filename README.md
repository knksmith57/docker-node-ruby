docker-node-ruby
================

## Example Dockerfile

```
FROM knksmith57/docker-node-ruby

RUN mkdir -p /app
WORKDIR /app
ADD package.json /app/package.json
ADD . /app
RUN npm install --unsafe-perm

# expose the necessary port(s)
EXPOSE 8080

CMD []
ENTRYPOINT ["npm", "start"]
```
