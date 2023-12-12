---
title: Monitoring a simple conversation with OpenAI
---

## Setup

Configure your Chainlit and OpenAI token. Chechout the [quickstart guide](/python-client/get-started/quickstart) for that.

## A conversation with myself

We can create a simple message to be displayed on Chainlit's platform:

```python
client = ChainlitClient()

with client.thread() as thread:
    message = client.message(content="Hello World", type="user_message")

client.wait_until_queue_empty() # All API calls to Chainlit are done in background

```

You should see a thread on the Chainlit platform :

TODO add image
