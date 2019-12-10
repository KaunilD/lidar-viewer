function [i,j,va,vb] = findcind(a,b)
%FINDCIND find indices of causal interpolation.
%   [I,J] = FINDCIND(A,B) returns the linear indices of A and B such that
%   A(I) are the nearest causal samples satisfying A(I)<=B(J).
%
%   [I,J,VA,VB] = FINDCIND(A,B) also returns the vectors VA and VB that
%   correspond to VA = A(I) and VB = B(I).
%
%   Example:
%   a = 1:0.1:10;
%   b = 2:2:20;
%   [i,j,va,vb] = findcind(a,b); % causal samples of a in b
%   disp([i,j,va,vb]);
%
%   [i,j,vb,va] = findcind(b,a); % causal samples of b in a
%   disp([i,j,vb,va]);
%
%   (c) 2007 Ryan M. Eustice
%            University of Michigan
%            eustice@umich.edu
%  
%-----------------------------------------------------------------
%    History:
%    Date            Who          What
%    -----------     -------      -----------------------------
%    07-31-2007      RME          Created and written.

if (numel(a) > length(a)) || (numel(b) > length(b))
    error('inputs A and B must be vectors');
end

% ensure column vectors
if (size(a,2) > 1); a = a'; end
if (size(b,2) > 1); b = b'; end

% find causal nearest neighbor index using algorithm from interp1q.m
[bi,k] = sort(b);
[dum,j] = sort([a;bi]);
r(j) = 1:length(j);
r = r(length(a)+1:end) - (1:length(bi));
r(k) = r;
r(b==a(end)) = length(a)-1;
j = find( (r>0) & (r<=length(a)) )';
i = r(j)';

if (nargout >= 3)
    va = a(i);
end
if (nargout >= 4)
    vb = b(j);
end
