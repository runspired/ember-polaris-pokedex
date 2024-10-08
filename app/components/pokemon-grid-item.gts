import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import Component from '@glimmer/component';
import type { Pokemon } from 'ember-polaris-pokedex/schemas/pokemon';
import { service } from '@ember/service';
import type RouterService from '@ember/routing/router-service';
import type { ImageFetch } from '@warp-drive/experiments/image-fetch';
import { cached } from '@glimmer/tracking';
import { getPromiseState } from '@warp-drive/ember';

export function preloadImage(imageUrl: string) {
  const img = new Image();
  img.src = imageUrl;
}

interface PokemonSignature {
  Args: { pokemon: Pokemon };
}

export default class PokemonGridItem extends Component<PokemonSignature> {
  @service declare router: RouterService;
  @service declare images: ImageFetch;

  transitionToPokemonDetails = (pokemon: Pokemon, event: MouseEvent) => {
    // Fallback for browsers that don't support this API:
    if (!document.startViewTransition) {
      this.router.transitionTo('pokemon.pokemon', pokemon.id?.toString());
      return;
    }

    const thumbnail = (event.target as HTMLElement).attributes.length
      ? (event.target as HTMLImageElement)
      : ((event.target as HTMLElement).querySelector(
          'img[data-pokemon-thumbnail]',
        ) as HTMLImageElement);
    thumbnail.style.viewTransitionName = 'full-embed';

    // With a transition:
    document.startViewTransition(() => {
      thumbnail.style.viewTransitionName = '';
      this.router.transitionTo('pokemon.pokemon', pokemon.id?.toString());
    });
  };

  preloadImage = (imageUrl: string) => {
    this.images.load(imageUrl);
  };

  @cached
  get thumbnailRequest() {
    return this.images.load(this.args.pokemon.image.thumbnail);
  }

  @cached
  get thumbnailUrl() {
    const state = getPromiseState(this.thumbnailRequest);
    if (state.isError || state.isPending) {
      return null;
    }
    return state.result;
  }

  <template>
    <button
      type='button'
      class='revealing-image group flex cursor-pointer flex-col items-center rounded-xl bg-gradient-to-br from-pink-100 to-yellow-100 p-4 shadow transition-shadow hover:shadow-md'
      {{on 'pointerenter' (fn this.preloadImage @pokemon.image.hires)}}
      {{on 'click' (fn this.transitionToPokemonDetails @pokemon)}}
    >
      {{#if this.thumbnailUrl}}
        <img
          data-pokemon-thumbnail
          class='block aspect-square w-full p-4 transition-transform group-hover:scale-125 group-hover:drop-shadow-xl'
          loading='lazy'
          src={{this.thumbnailUrl}}
          alt='{{@pokemon.name.english}} thumbnail'
        />
      {{else}}
        <div class='data-pokemon-thumbnail-loading'></div>
      {{/if}}
      <span class='mt-4 text-lg font-medium'>{{@pokemon.name.english}}</span>
    </button>
  </template>
}
