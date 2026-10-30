"""Select a pinned release from the public Guitar Pro Sparkle feed."""
import sys
import xml.etree.ElementTree as ET
from urllib.parse import urlsplit

feed, version, filename = sys.argv[1:]
for enclosure in ET.parse(feed).iter("enclosure"):
    if enclosure.get("{http://www.andymatuschak.org/xml-namespaces/sparkle}version") != version:
        continue
    url = enclosure.get("url", "")
    parsed = urlsplit(url)
    if (
        parsed.scheme == "https"
        and parsed.hostname == "download.assets-arobas-music.com"
        and parsed.path.endswith("/" + filename)
    ):
        print(url)
        break
else:
    sys.exit(
        f"Guitar Pro {version} ({filename}) is no longer in the update feed. "
        "Update the package version and hash, or override src with the matching local archive."
    )
