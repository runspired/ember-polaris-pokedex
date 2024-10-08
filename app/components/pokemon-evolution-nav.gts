import Component from '@glimmer/component';
import { get } from '@ember/helper';
import type { Pokemon } from 'ember-polaris-pokedex/schemas/pokemon';
import type RouterService from '@ember/routing/router-service';
import { service } from '@ember/service';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import type { ImageFetch } from '@warp-drive/experiments/image-fetch';

export function getPokemonById(pokemons: Pokemon[], id: string) {
  return pokemons.find((pokemon) => pokemon.id === id);
}

// https://raw.githubusercontent.com/IgnaceMaes/pokemon-data.json/master/images/pokedex/hires/005.png
function getHiresImageForId(id: string) {
  return `https://raw.githubusercontent.com/IgnaceMaes/pokemon-data.json/master/images/pokedex/hires/${id.padStart(
    3,
    '0',
  )}.png`;
}

export default class PokemonEvolutionNav extends Component<{
  Args: { pokemon: Pokemon };
}> {
  @service declare router: RouterService;
  @service declare images: ImageFetch;

  transitionToPokemonDetails = (
    pokemonId: string,
    direction: 'forwards' | 'backwards',
  ) => {
    // Fallback for browsers that don't support this API:
    if (!document.startViewTransition) {
      this.router.transitionTo('pokemon.pokemon', pokemonId.toString());
      return;
    }

    // With a transition:
    document.startViewTransition({
      // @ts-expect-error: No types for these options yet
      update: () => {
        this.router.transitionTo('pokemon.pokemon', pokemonId.toString());
      },
      types: ['slide', direction],
    });
  };

  preloadImageForPokemonId = (pokemonId: string) => {
    const url = getHiresImageForId(pokemonId);
    this.images.load(url);
    // preloadImage(getHiresImageForId(pokemonId));
  };

  <template>
    <section class='m-auto max-w-3xl'>
      <h3 class='mt-12 text-2xl'>Evolutions</h3>

      <div class='grid grid-cols-2 gap-8'>
        <div>
          {{#if @pokemon.evolution.prev}}
            <button
              type='button'
              class='flex w-full cursor-pointer flex-col items-center rounded-xl bg-gradient-to-br from-pink-100 to-yellow-100 p-4 shadow transition-shadow hover:shadow-md'
              {{on
                'click'
                (fn
                  this.transitionToPokemonDetails
                  (get @pokemon.evolution.prev 0)
                  'backwards'
                )
              }}
              {{on
                'pointerenter'
                (fn
                  this.preloadImageForPokemonId (get @pokemon.evolution.prev 0)
                )
              }}
            >
              ⏪ Previous
            </button>
          {{else}}
            <button
              type='button'
              class='flex w-full cursor-not-allowed flex-col items-center rounded-xl bg-gradient-to-br from-gray-100 to-slate-100 p-4 opacity-50 shadow'
            >
              ⏪ Previous
            </button>
          {{/if}}
        </div>
        <div class='flex flex-col gap-2'>
          {{#each @pokemon.evolution.next as |next|}}
            <button
              type='button'
              class='flex w-full cursor-pointer flex-col items-center rounded-xl bg-gradient-to-br from-pink-100 to-yellow-100 p-4 shadow transition-shadow hover:shadow-md'
              {{on
                'click'
                (fn this.transitionToPokemonDetails (get next 0) 'forwards')
              }}
              {{on
                'pointerenter'
                (fn this.preloadImageForPokemonId (get next 0))
              }}
            >
              Next ⏩
            </button>
          {{else}}
            <button
              type='button'
              class='flex w-full cursor-not-allowed flex-col items-center rounded-xl bg-gradient-to-br from-gray-100 to-slate-100 p-4 opacity-50 shadow'
            >
              Next ⏩
            </button>
          {{/each}}
        </div>
      </div>
    </section>
  </template>
}
