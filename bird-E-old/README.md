# bird-E dom compositor

> /!\ This is the **old** compositor using images cashing. The new one will
> be using built-in tools for faster, more efficent rendering.

This is an implementation of the HTML(5) DOM, in racket, made for the
Bad-Mitten Browser

> Keep in mind that while this library is supposed to be able to both keep track
> of the dom, and render the dom, it is __not__ intended to be complient to the
> ECMAScript API of the dom.
> 
> While I _would_ like to keep the two seperate (and sometimes conflicting)
> implmentations seperate, I _am_ keeping in mind that there is intended to be a
> compatibility layer written between the two for ECMAScript access to the dom,
> as according to the proper spec.
> 
> I do, however, plan on having this API _close_ to the actual API, to
> minimalize the size of the compatibility layer.

