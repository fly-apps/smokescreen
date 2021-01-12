# Smokescreen

Managing your outgoing web connections from Fly with Smokescreen

<!-- cut here-->

## Rationale

This App runs [Stripe's Smokescreen proxy](https://github.com/stripe/smokescreen) on Fly.

It is always worthwhile to control the outgoing traffic from your other applications. If your apps call other systems with user-entered URLs, say for triggering webhooks or reading responses from an API, then there is a possibility that that feature could be abused. A bad actor could enter URLs designed to access resources inside your application's private network, giving it the names of known machines or well-known private IP addresses. Depending on how your app responds may give that bad actor a clue on how your application works and from that, possibly stage an attack.

To handle this, Stripe created (and open-sourced), Smokescreen, an outbound proxy that makes sure that requests to the outside world from your applications aren't trying to probe your internal network. Out of the box, Smokescreen will check any request isn't destined for 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16" or fc00::/7. There's a lot more that Smokescreen can do around roles, ACLs, and TLS certificates, but that is outside the scope of this example.

## The Dockerfile

One thing with Smokescreen is that there is no binary executable distributed for it. That means it has to be built to deploy it. This example comes with a Dockerfile that does a multi-stage build - first compiling the code, then moving the executable to a clean image to run. 

## Deploying on Fly

The quickest way to initialize the app is to import the `fly.source.toml` file supplied:

```
fly init smokescreen-example --import fly.source.toml
```

Replace `smokescreen-example` with your preferred app name (`yourappname`) or omit it to have Fly generate a name for you. You may be prompted for which organization you want the app to run in. Ensure that it is running in the same organization as the apps you wish to manage their external calls.

Smokescreen runs on port 4750 and applications wishing to connect to it from within your Fly organization should send their requests to `yourappname.internal`. To connect to Smokescreen from outside the Fly environment, use [Fly's Wireguard](https://fly.io/docs/reference/wireguard/) to create a VPN into your Fly organization. 

To bring Smokescreen online, run:

```
fly deploy
```

## Testing

To test Smokescreen is running correctly, you can use `curl`. The -x option on curl tells it to use the following address and port as a proxy. Therefor the command:

```bash
curl -x yourappname.internal:4750 https://fly.io
```

Would attempt to use the proxy to contact the secure version of the fly.io site. If an attempt was made to connect to `localhost`, as a network mapper may do, this would happen:

```bash
curl -x yourappname.internal:4750 http://localhost/ 
Egress proxying is denied to host 'localhost': The destination address (127.0.0.1) was denied by rule 'Deny: Not Global Unicast'. destination address was denied by rule, see error.
```

## Notes

* Smokescreen is most useful from inside the 6PN Fly network for the organization. Although you could add an external service port to the `fly.toml` file, it would leave an open proxy on the network without a lot more configuration (including code) of Smokescreen.

## Discuss

* Discuss the Smokescreen example on its [dedicated community.fly.io topic](https://community.fly.io/t/new-smokescreen-example/466)

