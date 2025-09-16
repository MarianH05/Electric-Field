function safeDelete(h)
    if isempty(h), return; end
    for ii = 1:numel(h)
        if isgraphics(h(ii))
            try delete(h(ii)); catch, end
        end
    end
end
