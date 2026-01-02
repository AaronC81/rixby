explicit export is vital so you don't throw out all of your imports as exports

the idea doesn't really work without this

```ruby
export def x

end

export class X

end

export 3, as: Something
```

