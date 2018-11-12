import asyncio
import subprocess
import re
from collections import OrderedDict
import re

from mylogging import logger


def entity_count(name, log_string):
    m = re.search(r'Total {}:\s*([0-9,]+)'.format(name), log_string)
    if m:
        return float(m.group(1))
    else:
        return '???'


class SimplePreview:
    def __init__(self, factorio_binary):
        self.binary = factorio_binary
        self.lock = asyncio.Lock()
        self.entities = ['iron-ore', 'copper-ore', 'coal']

    async def __call__(self, map_gen_settings_path, image_path, log_path, scale=None):
        extra_args = []
        if scale is not None:
            extra_args += '--map-preview-scale', str(float(scale))
        with await self.lock:
            with open(log_path, 'w') as log_file:
                process = await asyncio.create_subprocess_exec(
                    self.binary,
                    '--generate-map-preview', image_path,
                    '--map-gen-settings', map_gen_settings_path,
                    '--report-quantities', ','.join(self.entities),
                    *extra_args,
                    stdout=log_file, stderr=subprocess.STDOUT
                )
                # TODO use wait_for with timeout
                await process.wait()

            with open(log_path, 'r') as log_file:
                log_string = log_file.read()

            entities = OrderedDict(
                (name, entity_count(name, log_string))
                for name in self.entities
            )
            with open(log_path, 'w') as log_file:
                log_file.write(log_string)
            logger.info('Detected entities: {}', entities)
            return entities

    async def get_version_str(self):
        with await self.lock:
            process = await asyncio.create_subprocess_exec(
                self.binary, '--version', stdout=subprocess.PIPE)
            output, _ = await process.communicate()
            match = re.search(r'Version: ([\.0-9]+)', output.decode())
            if not match:
                return '???'
            return match.group(1)