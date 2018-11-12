import click
import csv
import json
import asyncio
from copy import deepcopy

from mylogging import logger
from preview import SimplePreview


def mutate(config):
    assert config['autoplace_controls']['uranium-ore']['size'] == 'none'
    assert config['autoplace_controls']['enemy-base']['size'] == 'none'

    for cf, cfi in ('very-low', 0), ('low', 1), ('high', 3), ('very-high', 4), ('normal', 2):
        config['autoplace_controls']['coal']['frequency'] = cf
        yield config, '{}coal-{}'.format(cfi, cf)

    config['autoplace_controls']['uranium-ore']['size'] = 'normal'
    yield config, 'uranium'
    config['autoplace_controls']['enemy-base']['size'] = 'normal'
    yield config, 'xbiter-uranium'
    config['autoplace_controls']['uranium-ore']['size'] = 'none'
    yield config, 'xbiter'


@click.command()
@click.argument('factorio-binary', type=click.Path(exists=True, dir_okay=False))
@click.argument('seeds', type=click.File('r'))
@click.argument('config', type=click.File('r'))
def sweep(factorio_binary, seeds, config):
    seed_reader = csv.DictReader(seeds)
    preview = SimplePreview(factorio_binary)
    base_config = json.load(config)
    for row in seed_reader:
        seed = int(row['seed'])
        config = deepcopy(base_config)
        config['seed'] = seed
        print('{}'.format(row))
        if int(row['iron-ore']) < 13000 or int(row['copper-ore']) < 9000:
            continue
        for config_variant, variant in mutate(config):
            filename = 'preview-{:09}-{}.'.format(seed, variant)
            click.echo('generating {}'.format(filename))
            with open(filename + 'json', 'w') as f:
                json.dump(config_variant, f)

            loop = asyncio.get_event_loop()
            loop.run_until_complete(preview(filename + 'json', filename + 'png', '/tmp/' + filename + 'log'))


if __name__ == '__main__':
    sweep()
