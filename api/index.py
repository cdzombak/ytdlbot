from typing import Final

from flask import Flask, request

APP_HOST: Final = "0.0.0.0"
APP_PORT: Final = 5000

ENV_DEBUG: Final = "YTDLBOT_DEBUG"

app = Flask("ytdlbot")


@app.route("/add", methods=["POST"])
def post_add():
    url = request.json.get("url", "")
    url = url.replace("\t", "    ").strip()
    collection = request.json.get("collection", "")
    collection = collection.replace("\t", "    ").strip()

    if not url or not collection:
        return {
            "status": "error",
            "message": "keys 'url' and 'collection' are required",
        }, 400

    with open("/ytdlbot-media/_queue.txt", "a", encoding="utf-8") as f:
        f.write(collection + "\t" + url + "\n")

    return {
        "status": "ok",
        "message": "URL accepted",
    }, 202


@app.route("/collections", methods=["GET"])
def get_collections():
    return {
        "collections": sorted(
            [f.name for f in os.scandir("/ytdlbot-media") if f.is_dir()]
        ),
    }, 200


@app.route("/health", methods=["GET"])
def get_health():
    return "ytdlbot-api is online.", 200


if __name__ == "__main__":
    import os

    debug = os.getenv(ENV_DEBUG, "False").casefold() in ("true", "1")

    if debug:
        app.run(debug=True, host=APP_HOST, port=APP_PORT)
    else:
        from waitress import serve

        serve(app, host=APP_HOST, port=APP_PORT)
